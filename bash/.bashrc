# /etc/bashrc
#
# $Id: bashrc 97929 2010-09-21 02:07:14Z dturner $
# $URL: https://svn.vip.facebook.com/svnrootOps/opsfiles/branches/PROD/etc/bashrc $
#
# System wide functions and aliases
# Environment stuff goes in /etc/profile
#

if [ -f /etc/shellrc ]; then
  source /etc/shellrc
fi

# by default, we want this to get set.
# Even for non-interactive, non-login shells.
#

if [ $UID -gt 99 ] && [ "`id -gn`" = "`id -un`" ]; then
  umask 002
else
  umask 022
fi

# Set terminal prompt, including displaying the colo as part of the "hostname" section
# Added 11/05/07

if [ "$PS1" ]; then
  case $TERM in
  xterm*)
    if [ -e /etc/sysconfig/bash-prompt-xterm ]; then
       PROMPT_COMMAND=/etc/sysconfig/bash-prompt-xterm
    else
       PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\007"'
    fi
    ;;
  screen)
    if [ -e /etc/sysconfig/bash-prompt-screen ]; then
       PROMPT_COMMAND=/etc/sysconfig/bash-prompt-screen
    else
      PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\033\\"'
    fi
    ;;
  *)
    [ -e /etc/sysconfig/bash-prompt-default ] && PROMPT_COMMAND=/etc/sysconfig/bash-prompt-default
    ;;
  esac

  [ "$PS1" = "\\s-\\v\\\$ " ] && PS1="[\u@`uname -n | sed 's/.facebook.com//'` \w]\\$ "

  # Turn on checkwinsize
  shopt -s checkwinsize
fi

if ! shopt -q login_shell ; then # We're not a login shell
  for i in /etc/profile.d/*.sh; do
    if [ -r "$i" ]; then
      . $i
    fi
  done
  unset i
fi
# vim:ts=4:sw=4

# Commented out since a lot of older boxes don't use this, and it's features we really don't need anyway
# 11/07/07
#. /etc/bash_completion

if [ "`whoami`" == "root" ]; then
  if ! [ -d $HOME/.history-bash ]; then
      mkdir $HOME/.history-bash
  fi
  export HISTFILE=$HOME/.history-bash/"hist-`date +%Y-%W`.hist"
  if [[ ! -f $HISTFILE ]]; then
    LASTHIST=~/.history-bash/`ls -1tr ~/.history-bash/ | tail -1`;
    if [[ -f "$LASTHIST" ]]; then
      cat "$LASTHIST" > $HISTFILE
      echo "####### `date +%Y-%W-%w` : `date` #######" >> $HISTFILE
    fi
  fi
  history -n $HISTFILE
  export HISTSIZE=100000
  unset HISTFILESIZE
else
  export HISTFILE=$HOME/.bash_history

  # perform cert expiration check if login shell and not root user
  if shopt -q login_shell ; then
    DEFAULT_CERTS=( id_rsa-cert.pub id_dsa-cert.pub )
    for cert in ${DEFAULT_CERTS[@]}; do
      if [ -e $HOME/.ssh/$cert ]; then
        check_cert_expiration "$HOME/.ssh/$cert"
      fi
    done
  fi
fi

# forwarded by ssh, even when root certs are used
export SUDO_USER=$USER
