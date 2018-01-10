# tweets-hs
streaming tweets in haskell

## trying it out

If you have Entr, Nix and Cabal installed, you should be able to run `bash start.bash` in this directory to download all dependencies, configure cabal, and compile the project. If successful, you should see a 0 exit code, and entr should be waiting to recompile upon file change. After `C-c`ing, you should be able to run the project with `cabal run`.

