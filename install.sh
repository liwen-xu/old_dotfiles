#!/usr/bin/env bash

set -eu

platform=$(uname)
if [[ $platform == 'Darwin' ]]; then
  # Homebrew
  if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  echo "Updating homebrew"
  brew install --cask xquartz iterm2 keepingyouawake spectacle \
    mat visualvm google-backup-and-sync rstudio r mactex osxfuse \
    karabiner-elements maccy adoptopenjdk8
  
  brew install \
    zsh vim neovim tmux git tectonic wget pure fzf ranger tree \
    cmake coreutils cscope exiftool doxygen liboauth \
    python@3.9 pyenv anaconda go maven yarn bash-completion \
    reattach-to-user-namespace ripgrep vifm

  xcode-select --install
  
  # https://github.com/tmux/tmux/issues/1257#issuecomment-581378716
  /usr/local/opt/ncurses/bin/infocmp tmux-256color > ~/tmux-256color.info
  tic -xe tmux-256color tmux-256color.info
  infocmp tmux-256color | head

  # gcc/stdc++.h
  cd /Library/Developer/CommandLineTools/usr/include
  [ ! -d ./bits ] && sudo mkdir bits
  curl https://github.com/gcc-mirror/gcc/blob/master/libstdc%2B%2B-v3/include/precompiled/stdc%2B%2B.h > bits/stdc++.h
  cd ~

  source ~/miniconda3/bin/activate
  conda init zsh
  conda update -n base -c defaults conda
  conda install conda-build
else 
  rm -f ~/.tmux.conf
  grep -v reattach-to-user-namespace tmux.conf > ~/.tmux.conf
fi

if [ ! -e ~/.git-prompt.sh ]; then
  curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh
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

if [[ -f ~/.zshrc ]]; then
  mkdir -p ~/.zsh/plugins/bd
  curl https://raw.githubusercontent.com/Tarrasch/zsh-bd/master/bd.zsh > ~/.zsh/plugins/bd/bd.zsh
  print -- "\n# zsh-bd\n. \~/.zsh/plugins/bd/bd.zsh" >> ~/.zshrc
fi

tmux source-file ~/.tmux.conf

./makesymlinks.sh

vim -es -u ~/.vimrc +PlugInstall +qa
nvim -es -u ~/.config/nvim/init.vim +PlugInstall +qa
