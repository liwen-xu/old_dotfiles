#!/usr/bin/env bash

set -eu

BASE=$(pwd)
 
platform=$(uname)
if [[ $platform == 'Darwin' ]]; then
  # Homebrew
  if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # https://stackoverflow.com/questions/66859145/why-updating-homebrew-takes-forever
  if [[ ! -f /usr/local/Homebrew/.git/TMP_FETCH_FAILURES ]]; then
    touch /usr/local/Homebrew/.git/TMP_FETCH_FAILURES
  fi

  echo "Updating homebrew"
  for pkg in xquartz iterm2 keepingyouawake spectacle macfuse \
    visualvm rstudio r mactex xbar karabiner-elements miniconda \
    adoptopenjdk maccy visual-studio-code scroll-reverser; do
#    if ! brew list --cask $pkg &> /dev/null; then
    if ! brew list --cask -1 | grep -q "^${pkg}\$"; then
      brew install --cask $pkg
    fi
  done 
  
  brew install \
    zsh vim neovim tmux git tectonic wget pure fzf ranger tree \
    cmake coreutils cscope exiftool doxygen liboauth \
    python@3.9 pyenv anaconda go maven yarn bash-completion \
    reattach-to-user-namespace ripgrep vifm ncurses \
    prettierd

  touch "$HOME/Library/Application Support/Code/User/settings.json" && ln -sfv $BASE/vscode/settings.json $HOME/Library/Application\ Support/Code/User/settings.json
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
fi


./makesymlinks.sh

tmux source-file ~/.tmux.conf
if [[ $(uname) == 'Darwin' ]]; then
  cd ~
  /usr/local/opt/ncurses/bin/infocmp tmux-256color > ~/tmux-256color.info
  tic -xe tmux-256color tmux-256color.info
  infocmp tmux-256color | head
fi

mkdir -p ~/.config/nvim
touch ~/.config/nvim/init.vim
ln -sf $BASE/vim/init.vim ~/.config/nvim/init.vim

vim -es -u ~/.vimrc +PlugInstall +qa
nvim -es -u ~/.config/nvim/init.vim +PlugInstall +qa
