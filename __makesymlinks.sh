#!/usr/bin/env bash

shopt -s dotglob

BASE=$(pwd)
packages=([!.]*/)

declare -a skip_list=("bash_completion" "bin" "config" "vscode")

for package in "${packages[@]}"; do
  skip=0

  for dir in "${skip_list[@]}"; do
    if [ "$package" = "$dir" ]; then
      case "$(uname -s)" in
      Darwin*) skip=1 ;;
      *) ;;
      esac
    fi
  done

  if ! ((skip)); then
    for rc in $package*; do
      [[ ! $(basename $rc) == .* ]] && continue;
      ln -sfv "$BASE/$rc" ~/"$(basename $rc)"
    done
  fi
done


