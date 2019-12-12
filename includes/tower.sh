#!/usr/bin/env zsh

tower() {
  if [[ $1 ]]; then
    open $1 -a Tower
  else
    open . -a Tower
  fi
}
