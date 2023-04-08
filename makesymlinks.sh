#!/usr/bin/env bash

shopt -s dotglob

BASE=$(pwd)
packages=([!.]*/)

for package in "${packages[@]}"; do
  skip=0

  for dir in config bash_completion vscode; do
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

# neovim
mkdir -p ~/.config/nvim
touch ~/.config/nvim/init.vim
ln -sf $BASE/vim/init.vim ~/.config/nvim/init.vim

# vscode
brew install --cask visual-studio-code
ln -sfv $BASE/vscode/settings.json $HOME/Library/Application\ Support/Code/User/settings.json

