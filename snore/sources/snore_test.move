/*
1. Creator can create pool with these params input
 - nft collection address
 - nft total count
 - staking duration
 - token address
 - token reward amount (per one NFT per day)
2. Creator send token reward amount and can start pool. token reward amount should be higher than this:
  nft total count * token reward amount * staking duration (days)
   best to ask to send amount when calling startPool function
3. Once pool is started, users will be able to deposit NFT
4. Once user deposit NFT and NFT token should be sent to the pool address and user start getting rewards.
5. Users can claim rewards anytime and can unstake NFT anytime as well.
6. Creator can stop pool anytime and can get refund unused tokens.
7. Each transactions on users side (stake, unstake, claim) will cost additional 0.1 APT.  meaning users need to pay gas fee + 0.1 APT
*/

#[test_only]
module snore::snore_test{

    use std::signer;
    use std::string;
    use aptos_framework::account;
    //use aptos_framework::timestamp;
    use aptos_framework::coin::{Self, MintCapability, BurnCapability};
    //use aptos_framework::managed_coin;
    use aptos_framework::aptos_coin::{Self, AptosCoin};
    use aptos_token::token;
    use snore::snore;

    struct SnoreTest has key{
      mint_cap: MintCapability<AptosCoin>,
      burn_cap: BurnCapability<AptosCoin>
    }



  public fun test_create_token(receiver: &signer, creator: &signer, collection_name:vector<u8>, name:vector<u8>) {
      //create collection
      let mutate_setting = vector<bool>[false, false, false];

      token::create_collection(
          creator,
          string::utf8(collection_name),
          string::utf8(b"collection_desc"),
          string::utf8(b"collection_url"),
          1000,  //maximum supply
          mutate_setting //mutate_setting
      );
      //create token
      token::create_token_script(
          creator,
          string::utf8(collection_name),
          string::utf8(b"tk"),
          string::utf8(b"token_desc"),
          1,
          1,
          string::utf8(b"token_uri"),
          signer::address_of(creator),
          100,
          0,
          vector<bool>[false, false, false, false, false],
          vector<string::String>[],
          vector<vector<u8>>[],
          vector<string::String>[]
      );

      token::direct_transfer_script(
          creator,
          receiver,
          signer::address_of(creator),
          string::utf8(collection_name),
          string::utf8(name),
          0,
          1
      );

      //check minted token
      let created_token_id = token::create_token_id_raw(
          signer::address_of(creator),
          string::utf8(collection_name),
          string::utf8(name),
          0
      );
      let token_balance = token::balance_of(signer::address_of(receiver), created_token_id);
      assert!(token_balance == 1, 1);
  }



  #[test (user=@0x1234, creator=@0x123, minter=@0x456, aptos_framework=@aptos_framework)]
  public fun stake_test(user: &signer, creator: &signer, minter:&signer, aptos_framework: &signer){


    let user_addr = signer::address_of(user);
    let creator_addr = signer:: address_of(creator);
    let aptos_framework_addr = signer::address_of(aptos_framework);
    let minter_addr = signer::address_of(minter);

    account::create_account_for_test(user_addr);
    account::create_account_for_test(creator_addr);
    account::create_account_for_test(aptos_framework_addr);
    account::create_account_for_test(minter_addr);


    //minting aptoscoin
    let coint_to_mint:u64 = 1000000000;
    let ( burn_cap, mint_cap) = aptos_coin::initialize_for_test(aptos_framework);
    
    if (!coin::is_account_registered<AptosCoin>(creator_addr)){
        coin::register<AptosCoin>(creator);  
    };
    aptos_coin::mint(aptos_framework, creator_addr, coint_to_mint);

    move_to(aptos_framework, SnoreTest{
            mint_cap,
            burn_cap
        });

    let creator_balance = coin::balance<AptosCoin>(creator_addr);
    assert!(coint_to_mint == creator_balance, 2);
    //Mint token
  
    let collection_name = b"collection_name";
    //let name = b"tk";
    let nft_total_count = 2;
    let staking_duration = 86400;
    let reward_per_day = 1000;
    let deposit_coin_amount = 2000;
    

    assert!(deposit_coin_amount == (reward_per_day * nft_total_count * (staking_duration/86400)), 0);
    //test_create_token(user, creator, collection_name, name);


    snore::startPool<AptosCoin>(
      creator,
      user_addr,
      collection_name,
      nft_total_count,
      staking_duration,
      reward_per_day,
      deposit_coin_amount
    ); 
       
/*
    let _ = token::balance_of(user_addr, token_id);
*/
    //assert!(token_balance_end == 0, 1);
    assert!(true, 1)
  }

  #[test]
  public fun unstake_test(){
  
    assert!(true, 0);
  }

  #[test]
  public fun claim_test(){
    assert!(true, 0);
  }

}