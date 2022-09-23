# APTOS

## APTOS-CLI

### Init wallet
```
aptos init --profile wallet
```

### Account list
```
aptos account list
```

### Check modules
```
aptos account list --query modules --account wallet
```

### Compile
```
aptos move compile --package-dir transfer_value --named-addresses transfer_value=wallet
```

### Testing
```
aptos move test --package-dir transfer_value --named-addresses transfer_value=wallet



```

### Publish
```
aptos move publish --package-dir transfer_value/ --named-addresses transfer_value=test1
```

### Key generation
```
aptos key generate --output-file ./key.hex
```

### rotate-key
```
aptos account rotate-key  --new-private-key-file ./key.hex --profile test1
```

### Running function
```
aptos move run --function-id 99fa7bc4ccc55ae8a520b5d3d9dd2a20316818351f3d1da388b66931e59f53df::value::mint --args u64:10 string:TK 

```

###Init wallet
```
```

## References
[Youtube symposious](https://www.youtube.com/watch?v=zAaL8GSL0Y4)