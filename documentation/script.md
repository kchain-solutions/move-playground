```sh 
aptos run --script --signers Alice [--args x"68656C6C6F20776F726C64"] [--type-args "0x1::aptos_coin::AptosCoin"] [--expiration 1658432810] [--sequence-number 1] [--gas-price 1]
```
```move
script {
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    fun main(sender: &signer, receiver: address, amount: u64) {
        coin::transfer<AptosCoin>(sender, receiver, amount);
    }
}
```