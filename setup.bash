#! /usr/bin/env bash

cabal2nix . > default.nix && \
  nix-shell --run "cabal configure --enable-tests"
