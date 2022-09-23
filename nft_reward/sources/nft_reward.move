module nft_app::nft_reward{

    use aptos_framework::timestamp;
    use std::signer;
    use std::string::{Self, utf8};

    struct NftData has store, drop{
        name: string::String,
        url: string::String,
        timestamp: u64,
        old_timestamp: u64
    }
    
    struct Nft has key {
        nft_data: NftData
    }

    struct Reward has store, drop{
        value: u64
    }

    struct RewardBalance has key{
        reward: Reward
    }

    public entry fun init_resources(account: signer) {  
        let init_reward = Reward {value: 0};
        let nft_data = NftData {timestamp: 0, old_timestamp:0, name:utf8(b"Reward NFT"), url:utf8(b"aptos.com")};
        move_to(&account, RewardBalance{ reward: init_reward});
        move_to(&account, Nft{ nft_data: nft_data});
    }
    spec init_resources{
        let addr = signer::address_of(account);
        aborts_if exists<RewardBalance>(addr);
        aborts_if exists<Nft>(addr);
    }

    public entry fun init_timestamp(account: signer) acquires Nft{
        let account_addr = signer::address_of(&account);
        let current_timestamp = timestamp::now_seconds();

        let nft = borrow_global_mut<Nft>(account_addr);
        nft.nft_data.timestamp = current_timestamp;
    }
    spec init_timestamp {
        aborts_if !exists<Nft>(signer::address_of(&account));
    }

    //This method convert the Nft in Reward point amount
    public entry fun update_reward(account: signer) acquires Nft, RewardBalance{

        let account_addr = signer::address_of(&account);

        if(exists<Nft>(account_addr) && exists<RewardBalance>(account_addr)){

            let old_nft = borrow_global_mut<Nft>(account_addr);
            let timestamp_now = timestamp::now_seconds();
            let old_timestamp = old_nft.nft_data.timestamp;

            // update the nft timestamp value
            old_nft.nft_data.old_timestamp = old_timestamp;
            old_nft.nft_data.timestamp = timestamp::now_seconds();
            
            // this formula to calculate reward is an approximation for this example 
            let reward = timestamp_now - old_timestamp;

            //Update the reward amount
            let reward_balance = borrow_global_mut<RewardBalance>(account_addr);
            reward_balance.reward.value = reward;
        }
    }

    public entry fun balance_of(addr: address): u64 acquires RewardBalance{
        borrow_global<RewardBalance>(addr).reward.value
    }

    public entry fun cash_out(account: signer) acquires RewardBalance {
            let account_addr = signer::address_of(&account);
            let reward_balance = borrow_global_mut<RewardBalance>(account_addr);
            reward_balance.reward.value = 0;
    }

    
    // Safest approach would be to implement aptos_framework::coin
    public entry fun transfer(account: signer, to: address, amount:u64) acquires RewardBalance {
        let account_addr = signer::address_of(&account);
        let deposit_amount = withdraw(account_addr, amount);
        deposit(to, deposit_amount);

    }

    // This method is not safe
    public entry fun withdraw(addr: address, amount:u64): u64 acquires RewardBalance{
            let reward_balance = borrow_global_mut<RewardBalance>(addr);
            reward_balance.reward.value = reward_balance.reward.value - amount;
            amount
    } 
    spec withdraw{
        let balance = global<RewardBalance>(addr).coin.value;
        aborts_if !exists<RewardBalance>(addr);
        aborts_if balance < amount;
    }

    // This method is not safe
    public fun deposit(dst: address, amount:u64): u64 acquires RewardBalance{
        let reward_balance = borrow_global_mut<RewardBalance>(dst);
        reward_balance.reward.value = reward_balance.reward.value + amount;
        amount
    }

    public entry fun destroy_nft (account: signer) acquires Nft{
        let nft = move_from<Nft>(signer::address_of(&account));
        let Nft{nft_data: _} = nft;
    }


// ***TESTING***

    #[test (account = @0x01234)]
    public fun init_resources_test(account:signer) acquires Nft{
        let addr = signer::address_of(&account);
        
        init_resources(account);
        let nft = borrow_global<Nft>(addr);
        
        assert!(nft.nft_data.url==utf8(b"aptos.com"), 0);
    }

    #[test(account = @0x01234)]
    public fun init_timestamp_test(account: signer) acquires Nft{
        let addr = signer::address_of(&account);
        init_timestamp(account);
        let nft = borrow_global<Nft>(addr);
        assert!(nft.nft_data.timestamp > 0, 0);
    }
}


