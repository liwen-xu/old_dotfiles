#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

BASE=$(pwd)

for rc in .*; do
  mkdir -pv bak
  [ -e ~/"$rc" ] && mv -v ~/"$rc" bak/"$rc"
  ln -sfv "$BASE/$rc" ~/"$rc"
done

[ -e ~/z.sh ] && mv -v ~/z.sh bak/z.sh; ln -sfv "$BASE/z.sh" ~/z.sh

# git-prompt
if [ ! -e ~/.git-prompt.sh ]; then
  curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh
fi

mkdir -p ~/bin
for bin in $BASE/bin/*; do
  ln -svf "$bin" ~/bin
  
done

if [ "$(uname -s)" = 'Darwin' ]; then
  # Homebrew
  [ -z "$(which brew)" ] &&
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  brew tap universal-ctags/universal-ctags
  brew install --HEAD universal-ctags
  brew install zsh-completions

  gem install gem-ctags
  gem ctags
else
  rm -f ~/.tmux.conf
  grep -v reattach-to-user-namespace tmux.conf > ~/.tmux.conf
fi

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux source-file ~/.tmux.conf
