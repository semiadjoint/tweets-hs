#! /usr/bin/env bash

exec ag -g hs$ | \
  entr -s 'echo && \
          echo && \
          cabal build && \
          printf "\e[32mBuilt at $(date --iso-8601=seconds)\n\e[0m"'
