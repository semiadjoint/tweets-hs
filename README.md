# tweets-hs
streaming tweets in haskell

## trying it out

If you have Nix and Cabal installed, run 
```shell
bash setup.bash
```
in this directory to download all dependencies. Then, run 
```shell
bash run.bash <your-ini-file>
``` 
to start the project.

Your .ini file might look something like
```ini
[consumer]
key = mykey
secret = mysecret

[token]
key = mykey
secret = mysecret
```

## development 

If you have Entr, Nix and Cabal installed, you should be able to run
```shell
bash start.bash
```
in this directory to download all dependencies,
configure cabal, and compile the project. If successful, you should
see a 0 exit code, and entr should be waiting to recompile upon file
change. 

