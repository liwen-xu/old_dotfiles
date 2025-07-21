#zmodload zsh/zprof

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND="find . -maxdepth 1 | sed 's/^..//'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

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

setopt interactivecomments

if type brew &>/dev/null
then
  fpath+=("$(brew --prefix)/share/zsh/site-functions")
fi
fpath+=($HOME/.zsh/pure)

# Git completion
fpath+=$HOME/.zsh/_git

autoload -Uz compinit
if [ $(date +'%j') != $(/usr/bin/stat -f '%Sm' -t '%j' ${ZDOTDIR:-$HOME}/.zcompdump) ]; then
  compinit
else
  compinit -C
fi

autoload -U promptinit; promptinit
prompt pure

# zsh-bd
. $HOME/.zsh/plugins/bd/bd.zsh

# Z integration
source $HOME/z.sh
unalias z 2> /dev/null
z() {
  [ $# -gt 0 ] && _z "$*" && return
  cd "$(_z -l 2>&1 | fzf --height 40% --reverse +s --tac --query "$*" | sed 's/^[0-9,.]* *//')"
}

if command -v nvim > /dev/null 2>&1; then
  alias vi=nvim
  export EDITOR=nvim
fi

fzf-down() {
  fzf --height 50% "$@" --border
}

# fco - checkout git branch/tag
fco() {
  local tags branches target
  tags=$(git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
  branches=$(
    git branch --all | grep -v HEAD             |
    sed "s/.* //"    | sed "s#remotes/[^/]*/##" |
    sort -u          | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
  target=$(
    (echo "$tags"; echo "$branches") | sed '/^$/d' |
    fzf-down --no-hscroll --reverse --ansi +m -d "\t" -n 2 -q "$*") || return
  git checkout $(echo "$target" | awk '{print $2}')
}

# fshow - git commit browser
fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --header "Press CTRL-S to toggle sort" \
      --preview "echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |
                 xargs -I % sh -c 'git show --color=always % | head -200 '" \
      --bind "enter:execute:echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |
              xargs -I % sh -c 'vim fugitive://\$(git rev-parse --show-toplevel)/.git//% < /dev/tty'"
}

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

# bash completion
if [ -f $HOME/.zsh/bash_completion ]; then
#   . $HOME/.zsh/bash_completion
fi

zstyle ':completion:*:*:git:*' script ~/.zsh/_git
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' menu yes select

# Command line vi mode
set -o vi

# reverse search
bindkey -v
bindkey '^R' history-incremental-search-backward

# https://unix.stackexchange.com/questions/290392/backspace-in-zsh-stuck
bindkey -v '^?' backward-delete-char

# pyenv
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line -w
  else
    zle push-input -w
    zle clear-screen -w
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

print() {
  [ 0 -eq $# -a "prompt_pure_precmd" = "${funcstack[-1]}" ] || builtin print "$@";
}

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
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
#alias tmux='export TERM=screen-256color; /usr/local/bin/tmux'
alias tmux='SHELL=/usr/local/bin/zsh tmux -L zsh'
alias vim='vim -X -O'
alias ports='lsof -nP -iTCP -sTCP:LISTEN'
alias pip='pip3'

# git aliases
alias gs="git status"
alias gdc="git diff --cached"

# disable brew auto-cleanup policy
export HOMEBREW_NO_INSTALL_CLEANUP=TRUE

export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/bin:/usr/local/bin:/opt/homebrew/bin:$PATH
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

# nvm
export PATH="/opt/homebrew/opt/node@18/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#zprof
