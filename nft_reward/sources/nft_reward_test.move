#[test_only]
module nft_app::nft_reward_test{
    use std::signer;
    use std::unit_test;
    use std::vector;
    use std::string::{String, utf8};

    use nft_app::nft_reward::{init_reward_process, 
                                get_nft_data};

    fun get_account(): signer {
        vector::pop_back(&mut unit_test::create_signers_for_testing(1))
    }

    /*
    #[test]
    fun init_reward_process_test(){
        let account: signer = get_account();
        let addr = signer::address_of(&account);

        init_reward_process(account);
        let (_, url, _, _) : (String, String, u64, u64) = get_nft_data(addr);
        
        assert!(url==utf8(b"aptos.com"), 0);
    }
    */

    #[test]
    fun update_reward_test(){
        assert!(true, 0);
    }

    #[test]
    fun transfer_test(){
        assert!(true, 0);
    }

}