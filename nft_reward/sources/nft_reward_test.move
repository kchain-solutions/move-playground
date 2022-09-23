#[test_only]
module nft_app::nft_reward_test{
    use std::unit_test;
    use std::vector;

    fun get_account(): signer {
        vector::pop_back(&mut unit_test::create_signers_for_testing(1))
    }


    #[test]
    fun update_reward_test(){
        assert!(true, 0);
    }

    #[test]
    fun transfer_test(){
        assert!(true, 0);
    }

}