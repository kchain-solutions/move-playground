module BuyToken::store{
   
    use std::signer;
    use std::string {String};
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_token::token;

    const ADMIN = @BuyToken;

    public entry fun mint_tokens(creator,
            collection_name:String,
            token_name:String,
            string::utf8(b"Hello, Token"),
            amount:u64,
            token_max:u64,
            string::utf8(b"https://aptos.dev"),
            signer::address_of(creator),
            100,
            0,
    
    ){
        let addr = 


    }

}

/*
 #[test_only]
    public entry fun create_collection_and_token(
        creator: &signer,
        amount: u64,
        collection_max: u64,
        token_max: u64
    ): TokenId acquires Collections, TokenStore {
        use std::string;
        use std::bcs;
        let mutate_setting = vector<bool>[false, false, false];

        create_collection(
            creator,
            get_collection_name(),
            string::utf8(b"Collection: Hello, World"),
            string::utf8(b"https://aptos.dev"),
            collection_max,
            mutate_setting
        );

        let default_keys = vector<String>[string::utf8(b"attack"), string::utf8(b"num_of_use")];
        let default_vals = vector<vector<u8>>[bcs::to_bytes<u64>(&10), bcs::to_bytes<u64>(&5)];
        let default_types = vector<String>[string::utf8(b"u64"), string::utf8(b"u64")];
        let mutate_setting = vector<bool>[false, false, false, false, true];
        create_token_script(
            creator,
            get_collection_name(),
            get_token_name(),
            string::utf8(b"Hello, Token"),
            amount,
            token_max,
            string::utf8(b"https://aptos.dev"),
            signer::address_of(creator),
            100,
            0,
            mutate_setting,
            default_keys,
            default_vals,
            default_types,
        );
        create_token_id_raw(signer::address_of(creator), get_collection_name(), get_token_name(), 0)
    }
*/