#! /usr/env bash

main() {
  exec cabal run -- --config-file=$1
}

main "$@"
