module snore::snore{
    use std::signer;
    use std::string;
    use std::vector;
    //use std::debug; //Valerio edited
    use aptos_framework::coin;
    use aptos_std::type_info;
    use aptos_token::token;
    use aptos_framework::account;
    use aptos_framework::timestamp;
    use aptos_framework::aptos_coin::AptosCoin;

    const INVALID_PARAMETER:u64 = 1;
    const INVALID_REWARD_TOKEN:u64 = 2;
    const INVALID_INSUFFICIENT_BALANCE:u64 = 3;
    const ALREADY_EXIST_POOL: u64 = 4;
    const INVALID_TOKEN: u64 = 5;
    const CAN_NOT_STAKE: u64 = 6;
    const NOT_STAKED: u64 = 7;
    const INVALID_PERMISSION: u64 = 8;

    const MODULE_POOL: address = @snore;

    const FEE: u64 = 1000; // 0.1 APTOS

    struct SnorePool has key{
        collection_creator: address,
        collection_name: string::String,
        nft_total_count: u64,
        staking_amount: u64,
        staking_duration: u64, // in seconds
        reward_per_day: u64, // per one NFT per day
        reward_coin_name: string::String,
        pool_addr: address,
        pool_signer_cap: account::SignerCapability,
        is_start: bool
    }


    struct SnoreStake has key{
        token_ids: vector<token::TokenId>,
        update_time: vector<u64>, //rewarded time
    }



    public entry fun startPool<CoinType>(
        creator: &signer,
        collection_creator: address,
        collection_name: vector<u8>,
        nft_total_count: u64,
        staking_duration: u64,
        reward_per_day: u64,
        deposit_coin_amount: u64
    ){

        assert!( staking_duration >0, INVALID_PARAMETER);
        assert!( reward_per_day >0, INVALID_PARAMETER);

        let creator_addr = signer::address_of(creator);

        let (pool_signer, pool_signer_capability) = account::create_resource_account(creator, collection_name);

        assert!( coin::is_account_registered<CoinType>(creator_addr), INVALID_REWARD_TOKEN);
        assert!( coin::balance<CoinType>(creator_addr) >= deposit_coin_amount, INVALID_INSUFFICIENT_BALANCE);
        assert!(!exists<SnorePool>(creator_addr), ALREADY_EXIST_POOL);
        
        let needed_reward_amount = nft_total_count * reward_per_day * staking_duration/86400;
        assert!(needed_reward_amount >= deposit_coin_amount, INVALID_INSUFFICIENT_BALANCE);

        //this code was deprecated Valerio Edited
        //token::initialize_token_script(&pool_signer);
        token::initialize_token_store(&pool_signer);

        //pool signer has to register CoinType Valerio Edited
        if (!coin::is_account_registered<CoinType>(signer::address_of(&pool_signer))){
            coin::register<CoinType>(&pool_signer);  
        };
        //transfer reward_coin to Pool addr
        coin::transfer<CoinType>(creator, signer::address_of(&pool_signer), deposit_coin_amount);

        move_to(creator, SnorePool{
            collection_creator,
            collection_name: string::utf8(collection_name),
            nft_total_count,
            staking_amount: 0,
            staking_duration,
            reward_per_day,
            reward_coin_name: type_info::type_name<CoinType>(),
            pool_addr: signer::address_of(&pool_signer),
            pool_signer_cap: pool_signer_capability,
            is_start: true
        });

    }

    public entry fun stake<CoinType>(
        user: &signer,
        collection_creator: address,
        collection_name: vector<u8>,
        token_name: vector<u8>
    ) acquires SnorePool, SnoreStake {
        let user_addr = signer::address_of(user);
        let token_id = token::create_token_id_raw(
                                    collection_creator,
                                    string::utf8(collection_name),
                                    string::utf8(token_name),
                                    0
                        );
        assert!( token::balance_of(user_addr, token_id) != 0, INVALID_TOKEN);

        let snore_pool = borrow_global_mut<SnorePool>(MODULE_POOL);

        assert!( snore_pool.collection_creator == collection_creator, INVALID_TOKEN);
        assert!( snore_pool.collection_name == string::utf8(collection_name), INVALID_TOKEN);
        assert!( snore_pool.staking_amount < snore_pool.nft_total_count, CAN_NOT_STAKE);
        assert!( snore_pool.is_start, CAN_NOT_STAKE);
        assert!( snore_pool.reward_coin_name == type_info::type_name<CoinType>(), INVALID_PARAMETER);

        if ( exists<SnoreStake>(user_addr) ){
            let stake_data = borrow_global_mut<SnoreStake>(user_addr);
            vector::push_back<token::TokenId>(&mut stake_data.token_ids, token_id);
            vector::push_back(&mut stake_data.update_time, timestamp::now_seconds());
        }else{
            let token_ids= vector::empty<token::TokenId>();
            vector::push_back(&mut token_ids, token_id);
            let update_time = vector::empty<u64>();
            vector::push_back(&mut update_time, timestamp::now_seconds());
            move_to( user, SnoreStake{
                token_ids,
                update_time
            });
        };
        snore_pool.staking_amount = snore_pool.staking_amount + 1;
        //transfer NFT to Pool_Signer
        token::transfer(user, token_id, snore_pool.pool_addr, 1);

        //fee
        coin::transfer<AptosCoin>(user, MODULE_POOL, FEE);
    }

    public entry fun unstake<CoinType>(
        user: &signer,
        collection_creator: address,
        collection_name: vector<u8>,
        token_name: vector<u8>
    ) acquires SnorePool, SnoreStake{
        let user_addr = signer::address_of(user);

        let snore_pool = borrow_global<SnorePool>(MODULE_POOL);
        let pool_signer = account::create_signer_with_capability(&snore_pool.pool_signer_cap);
        let token_id = token::create_token_id_raw(
                                    collection_creator,
                                    string::utf8(collection_name),
                                    string::utf8(token_name),
                                    0
                        );
        assert!( exists<SnoreStake>(user_addr), NOT_STAKED );
        assert!( snore_pool.reward_coin_name == type_info::type_name<CoinType>(), INVALID_PARAMETER);

        let stake_data = borrow_global_mut<SnoreStake>(user_addr);

        let (flag, index) = vector::index_of(&stake_data.token_ids, &token_id);
        assert!(flag, NOT_STAKED);

        let updated_time = vector::borrow(&stake_data.update_time, index);

        let now_seconds = timestamp::now_seconds();
        if (*updated_time < now_seconds){
            //transfer reward token
            let reward_amount = (now_seconds - *updated_time) * (snore_pool.reward_per_day) / 86400;
            coin::transfer<CoinType>(&pool_signer, user_addr, reward_amount);
        };
        //remove stake info
        vector::remove(&mut stake_data.token_ids, index);
        vector::remove(&mut stake_data.update_time, index);
        //transfer NFt from Pool to User
        token::transfer(&pool_signer, token_id, user_addr, 1);
        //fee
        coin::transfer<AptosCoin>(user, MODULE_POOL, FEE);
    }

    public entry fun claim<CoinType>(
        user: &signer
    ) acquires SnorePool, SnoreStake{
        let user_addr = signer::address_of(user);
        let snore_pool = borrow_global<SnorePool>(MODULE_POOL);
        let pool_signer = account::create_signer_with_capability(&snore_pool.pool_signer_cap);
        assert!( exists<SnoreStake>(user_addr), NOT_STAKED );
        assert!( snore_pool.reward_coin_name == type_info::type_name<CoinType>(), INVALID_PARAMETER);

        let stake_data = borrow_global_mut<SnoreStake>(user_addr);
        let stake_count = vector::length<u64>(&stake_data.update_time);
        let i: u64 = 0;
        let total_reward_amount: u64 = 0;
        let now_seconds = timestamp::now_seconds();

        let new_updated_time = vector::empty<u64>();

        while (i < stake_count) {
            let update_time = vector::borrow<u64>(&mut stake_data.update_time, i);
            total_reward_amount = total_reward_amount + ( (now_seconds - *update_time) * snore_pool.reward_per_day / 86400 );
            i = i + 1;
            vector::push_back(&mut new_updated_time, now_seconds);
        };

        stake_data.update_time = new_updated_time;

        coin::transfer<CoinType>(&pool_signer, user_addr, total_reward_amount);
        //fee
        coin::transfer<AptosCoin>(user, MODULE_POOL, FEE);
    }

    public entry fun stop_staking(admin: &signer) acquires SnorePool{
        let admin_addr = signer::address_of(admin);
        assert!( admin_addr == MODULE_POOL, INVALID_PERMISSION );
        let snore_pool = borrow_global_mut<SnorePool>(MODULE_POOL);
        snore_pool.is_start = false;
    }

}