#zmodload zsh/zprof

[ -f "$LOCAL_ADMIN_SCRIPTS/master.zshrc" ] && source "$LOCAL_ADMIN_SCRIPTS/master.zshrc"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Disable C-S and C-Q
if [[ -t 0 && $- = *i* ]]
then
    stty -ixon
fi 

# Disable globbing
set -o no_extended_glob

# Don't save duplicate commands in history
setopt HIST_IGNORE_DUPS

export GPG_TTY=$(tty)
export EDITOR=vim
export PAGER=less
export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
autoload -U colors
colors
setopt prompt_subst

# disable brew auto-cleanup policy
export HOMEBREW_NO_INSTALL_CLEANUP=TRUE

export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/bin:/usr/local/bin:/opt/homebrew/bin:$PATH
export PATH="/opt/homebrew/opt/node@18/bin:$PATH"
export PATH="$HOME/bin:/usr/local/Cellar/tmux/3.3a_1/bin:$PATH"
# openssl
export PATH="/usr/local/opt/openssl@1.1/bin/:$PATH"
export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"
# llvm
export LDFLAGS="-L/usr/local/opt/llvm/lib"
export CPPFLAGS="-I/usr/local/opt/llvm/include"
export PATH="/usr/local/opt/llvm/bin:$PATH"
export PATH=$PATH:/opt/local/bin:/opt/local/sbin:/usr/bin/c++:/usr/bin/make

if command -v nvim > /dev/null 2>&1; then
  alias vi=nvim
  export EDITOR=nvim
fi

# Replicate the bash vim mode behavior on 'v'
edit-command-line() {
  local tmpfile
  tmpfile=$(mktemp)
  echo "${(z)BUFFER}" > $tmpfile
  vim $tmpfile </dev/tty # suppress "Vim: Warning: Input is not from a terminal"
  BUFFER=$(< $tmpfile)
  rm -f $tmpfile
  zle .reset-prompt
}
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

#alias rm='rm -i'
alias gitcleanbranch='git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d'
alias mydu='du -ks * | sort -nr | cut -f2 | sed '"'"'s/^/"/;s/$/"/'"'"' | xargs du -sh'
alias grepr='grep -r -n --color=auto'
alias ipython='ipython notebook --matplotlib inline'
alias ls='ls -G'
alias l='ls -alF'
alias ll='ls -l'
alias mv='mv -i'
alias cp='cp -i'
alias mydu='du -ks * | sort -nr | cut -f2 | sed '"'"'s/^/"/;s/$/"/'"'"' | xargs du -sh'
alias screen='screen -e\`n -s /bin/bash'
alias tmux='export TERM=screen-256color; /usr/local/bin/tmux'
alias vim='vim -X -O'
alias ports='lsof -nP -iTCP -sTCP:LISTEN'

# git aliases
alias gs="git status"
alias gdc="git diff --cached"

alias doc="docker"
alias dcc="docker-compose"

# bash completion
if [ -f $HOME/.zsh/bash_completion ]; then
#   . $HOME/.zsh/bash_completion
fi

# Command line vi mode
set -o vi

# reverse search
bindkey -v
bindkey '^R' history-incremental-search-backward

# https://unix.stackexchange.com/questions/290392/backspace-in-zsh-stuck
bindkey -v '^?' backward-delete-char

# zsh prompt formatting
fpath+=$HOME/.zsh/pure

# zsh compsys
autoload -Uz compinit && compinit
_comp_options+=(globdots)

autoload -U promptinit; promptinit
prompt pure

print() {
  [ 0 -eq $# -a "prompt_pure_precmd" = "${funcstack[-1]}" ] || builtin print "$@";
}

# zsh-bd
. ~/.zsh/plugins/bd/bd.zsh

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
if [[ -d "$PYENV_ROOT}" ]]; then
  pyenv () {
    if ! (($path[(Ie)${PYENV_ROOT}/bin])); then
      path[1,0]="${PYENV_ROOT}/bin"
    fi
    eval "$(command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH")"
    eval "$(pyenv init -)"
    pyenv "$@"
    unfunction pyenv
  }
else
  unset PYENV_ROOT
fi

# bleh forget lazy loading
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

#https://github.com/undg/zsh-nvm-lazy-load/blob/master/zsh-nvm-lazy-load.plugin.zsh
load-nvm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
}

nvm() {
    unset -f nvm
    load-nvm
    nvm "$@"
}

node() {
    unset -f node
    load-nvm
    node "$@"
}

npm() {
    unset -f npm
    load-nvm
    npm "$@"
}

yarn() {
    unset -f yarn
    load-nvm
    yarn "$@"
}

lazy_conda_aliases=('python' 'conda' 'python3')

load_conda() {
  for lazy_conda_alias in $lazy_conda_aliases
  do
    unalias $lazy_conda_alias
  done

  __conda_prefix="$HOME/.miniconda3"

  __conda_setup="$('/usr/local/Caskroom/miniforge/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__conda_setup"
  else
      if [ -f "/usr/local/Caskroom/miniforge/base/etc/profile.d/conda.sh" ]; then
          . "/usr/local/Caskroom/miniforge/base/etc/profile.d/conda.sh"
      else
          export PATH="/usr/local/Caskroom/miniforge/base/bin:$PATH"
      fi
  fi
  unset __conda_setup
  
  unset __conda_prefix
  unfunction load_conda
}

for lazy_conda_alias in $lazy_conda_aliases
do
  alias $lazy_conda_alias="load_conda && $lazy_conda_alias"
done

#zprof

