#! /usr/bin/env bash

exec ag -g hs$ | \
  entr -s "echo && echo && cabal build && echo Built at $(date --iso-8601=seconds)"
