#!/usr/bin/env bash

set -eu

BASE=$(pwd)
#for rc in tmux.conf gitconfig vimrc zshrc; do
#  ln -sfv "$BASE/$rc" ~/."$rc"
#done
./makesymlinks.sh

# git-prompt
if [ ! -e ~/.git-prompt.sh ]; then
  curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh
fi

platform=$(uname)
if [[ $platform == 'Darwin' ]]; then
  if ! command -v brew &> /dev/null; then
    echo "Installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew update
  brew install \
    zsh vim neovim tmux git tectonic wget pyenv pure \
    ncurses

  # https://github.com/tmux/tmux/issues/1257#issuecomment-581378716
  /usr/local/opt/ncurses/bin/infocmp tmux-256color > ~/tmux-256color.info
  tic -xe tmux-256color tmux-256color.info
  infocmp tmux-256color | head

  echo "Curling from gcc/libstdc++-v3/include/precompiled/stdc++.h"
  cd /Library/Developer/CommandLineTools/usr/include
  [ ! -d ./bits ] && sudo mkdir bits
  curl https://github.com/gcc-mirror/gcc/blob/master/libstdc%2B%2B-v3/include/precompiled/stdc%2B%2B.h > bits/stdc++.h
  cd ~

  ln -sfv $BASE/vscode/settings.json $HOME/Library/Application\ Support/Code/User/settings.json
else 
  rm -f ~/.tmux.conf
  grep -v reattach-to-user-namespace tmux.conf > ~/.tmux.conf
fi

if [[ ! -d ~/.fzf ]]; then
  echo "Installing fzf"
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install --all 
fi

if [[ ! -f ~/.vim/autoload/plug.vim ]]; then
  echo "Installing vim-plug"
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

if [[ ! -f ~/.local/share/nvim/site/autoload/plug.vim ]]; then
  echo "Installing vim-plug (nvim)"
  sh -c 'curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
fi

if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  echo "Installing Tmux Plugin Manager"
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

tmux source-file ~/.tmux.conf

vim -es -u ~/.vimrc +PlugInstall +qa
nvim -es -u ~/.config/nvim/init.vim +PlugInstall +qa
