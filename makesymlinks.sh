#!/usr/bin/env bash

BASE=$(pwd)
packages=(*/)

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
    for f in `find $package -type f -name '.*'`; do 
      rc=$(basename $f)
      ln -sfv "$BASE/$package/$rc" ~/"$rc"
    done
  fi
done

mkdir -p ~/.config/nvim
touch ~/.config/nvim/init.vim
ln -sf $BASE/vim/init.vim ~/.config/nvim/init.vim
vim -es -u ~/.vimrc +PlugInstall +qa
nvim -es -u ~/.config/nvim/init.vim +PlugInstall +qa
