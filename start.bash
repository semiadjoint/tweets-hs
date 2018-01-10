#! /usr/bin/env bash

cabal2nix . > default.nix && \
  nix-shell --run "cabal configure" && \
  exec ag -g hs$ | \
    entr -s "echo && echo && cabal build && echo Built at $(date --iso-8601=seconds)"
