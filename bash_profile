# shellcheck disable=SC2148
# ============================== BASH PROFILE ==================================
pathadd() {
  ARG="$1"
  if [ -d "${ARG}" ] && [[ ":${PATH}:" != *":${ARG}:"* ]]; then
    export PATH="${ARG}${PATH:+":${PATH}"}"
  fi
}

if which brew &> /dev/null; then
  BREW_PREFIX="$(brew --prefix)"
fi

if [ -n "${TMUX}" ] && [ -f /usr/libexec/path_helper ]; then
  export PATH=""
  source /etc/profile
fi

if [ -z "${LC_LOGINUSER}" ]; then
  if logname &> /dev/null ; then
    LC_LOGINUSER="$(logname)"
  else
    LC_LOGINUSER="$(id -un)"
  fi
  LC_LOGINHOST="$(hostname -s)"
  LC_LOGINSYSN="$(uname -s)"

  export LC_LOGINHOST
  export LC_LOGINSYSN
  export LC_LOGINUSER
fi

pathadd /usr/local/sbin
pathadd "${HOME}/Git/github/depot_tools"
pathadd "${HOME}/.bin"
pathadd "${HOME}/.bin/$(uname -s)"

if [[ "${LC_LOGINHOST}" != "$(hostname -s)" ]]; then
  pathadd "${HOME}/.bin/remote_utils"
fi

if [ -d "${HOME}/.pumpkin" ]; then
  export PUMPKIN_HOME="${HOME}/.pumpkin"
fi

# Use brewed python
if which brew &> /dev/null; then
    pathadd "${BREW_PREFIX}/opt/python/libexec/bin"
fi

# Wrapper for python virtualenvs
if which brew &> /dev/null \
     && [ -f "${BREW_PREFIX}/bin/virtualenvwrapper.sh" ]; then
  export WORKON_HOME="${HOME}/.virtualenvs"
  # These need to be set explicitly for brewed python
  export VIRTUALENVWRAPPER_PYTHON=/usr/local/opt/python/libexec/bin/python
  export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
  source "${BREW_PREFIX}/bin/virtualenvwrapper.sh"
elif [ -f /usr/share/virtualenvwrapper/virtualenvwrapper.sh ]; then
  export WORKON_HOME="${HOME}/.virtualenvs"
  source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
fi

# Android stuff
if which brew &> /dev/null && [ -d "${BREW_PREFIX}/Cellar/android-ndk-r10e/r10e" ]; then
  export ANDROID_NDK="${BREW_PREFIX}/Cellar/android-ndk-r10e/r10e"
  export NDK_HOME="${BREW_PREFIX}/Cellar/android-ndk-r10e/r10e"
fi
if which brew &> /dev/null && [ -d "${BREW_PREFIX}/Cellar/android-sdk/22.0.5_1" ]; then
  export ANDROID_HOME="${BREW_PREFIX}/Cellar/android-sdk/22.0.5_1"
  pathadd "${ANDROID_HOME}/platform-tools"
  pathadd "${ANDROID_HOME}/tools"
fi

# RBEnv
if which rbenv &> /dev/null; then
  eval "$(rbenv init -)"
fi

# Kubernetes
if which kubectl &> /dev/null && [ -d "${HOME}/.kube" ]; then
  while read -r file; do
    export KUBECONFIG="${file}:${KUBECONFIG}"
  done < <(find "${HOME}/.kube" -name "config-*")
fi

# Golang
if which go &> /dev/null && [ -d "${HOME}/.go" ]; then
  export GOPATH="${HOME}/.go"
  pathadd "${GOPATH}/bin"
  if which brew &> /dev/null; then
    export GOROOT="${BREW_PREFIX}/opt/go/libexec"
    pathadd "${GOROOT}/bin"
  fi
fi

if which brew &> /dev/null; then
  export HOMEBREW_NO_GITHUB_API=1
fi

# ============================ TERMINAL OPTIONS ================================

# Make vim the default editor.
export EDITOR='vim'

# Prefer US English and use UTF-8.
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Set colors
if [ -f "${HOME}/.bash_colors" ]; then
  source "${HOME}/.bash_colors"
fi

# Enable colors for tools
#export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
# http://askubuntu.com/a/17300
# https://github.com/apjanke/oh-my-zsh-custom/blob/master/lscolors.zsh
# http://www.bigsoft.co.uk/blog/index.php/2008/04/11/configuring-ls_colors
if (ls --color &> /dev/null); then
  alias ls='ls --color=auto'
  export LS_COLORS='di=1;34:ln=1;36:so=1;35:pi=33;40:ex=1;32:bd=1;33;40:cd=1;33;40:su=30;43:sg=37;41:tw=37;44:ow=1;35'
else
  export CLICOLOR='Yes'
  export LSCOLORS='ExGxFxdaCxDADAadhbheFx'
  export TREE_COLORS='ln=36'
fi

# Highlight section titles in manual pages.
export LESS_TERMCAP_md="${ORANGE}"

# Put timestamps in bash history
export HISTTIMEFORMAT='%F %T '
# Don't put duplicate commands into the history
export HISTCONTROL='ignoreboth'
# Don't record these commands in the history; who cares about ls?
export HISTIGNORE='pwd:ls:history:'
# Store more history
export HISTSIZE=10000
# Append to history, don't overwrite it
shopt -s histappend

# A setting that does its best to keep ssh connections from freezing
export AUTOSSH_POLL=30

# =============================== COMPLETIONS ==================================

# Add tab completion for many Bash commands
if which brew > /dev/null && [ -f "${BREW_PREFIX}/etc/bash_completion" ]; then
  source "${BREW_PREFIX}/etc/bash_completion"
elif [ -f /usr/share/bash-completion/bash_completion ]; then
  source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
fi

# Git completion
if [ -f "${HOME}/.git-completion.bash" ]; then
  source "${HOME}/.git-completion.bash"
fi

# Azure cli completion
if [ -f "${HOME}/.azure-completion.bash" ]; then
  source "${HOME}/.azure-completion.bash"
fi

# ============================== PROMPT SETUP ==================================

# Git prompt setup
if [ -f "${HOME}/.git-prompt.sh" ]; then
  source "${HOME}/.git-prompt.sh"
elif [ -f /etc/bash_completion.d/git-prompt ]; then
  source /etc/bash_completion.d/git-prompt
elif [ -f /usr/lib/git-core/git-sh-prompt ]; then
  source /usr/lib/git-core/git-sh-prompt
fi

if type -t __git_ps1 &> /dev/null; then
  export GIT_PS1_SHOWDIRTYSTATE=1
  export GIT_PS1_SHOWUNTRACKEDFILES=1
  export GIT_PS1_SHOWCOLORHINTS=1
  export GIT_PS1_SHOWUPSTREAM='auto'
fi

if [ -f "${HOME}/.bash_prompt" ]; then
  source "${HOME}/.bash_prompt"
fi

# ============================ HELPER FUNCTIONS ================================

# Abbreviate given path Vim style
abbrev-path() {
  p="${1#${HOME}}"
  if [[ "${1}" != "${p}" ]]; then
    echo -n '~'
  fi
  sed 's:\([^/]\)[^/]*/:\1/:g' <<< "${p}"
}

# Get statistics of used commands
commandstats() {
  history | awk '{print $4}' | awk 'BEGIN {FS="|"} {print $1}' | sort | uniq -c | sort -rn | head -30
}

# Remove stopped containers and noname images
docker-clean() {
  docker container prune -f
  docker images | grep '^<none>' | awk '{print $3}' | xargs docker rmi
}

# Get escape code for a character
escape() {
  printf "\\\x%s" "$(printf '%s' "$@" | xxd -p -c1 -u)"
  # print a newline unless we’re piping the output to another program
  if [ -t 1 ]; then
    echo ""
  fi
}

# Extract most know archives with one command
extract () {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1"    ;;
      *.tar.gz)  tar xzf "$1"    ;;
      *.bz2)     bunzip2 "$1"    ;;
      *.rar)     unrar e "$1"    ;;
      *.gz)      gunzip "$1"     ;;
      *.tar)     tar xf "$1"     ;;
      *.tbz2)    tar xjf "$1"    ;;
      *.tgz)     tar xzf "$1"    ;;
      *.zip)     unzip "$1"      ;;
      *.Z)       uncompress "$1" ;;
      *)         echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Show directory structure as a tree from `pwd`
lstree() {
  local -r shortpath="$(basename "$(pwd)")"
  local -r output="$(tree -C -d --noreport "$@")"

  (
    echo "${output}" | head -n 1 | sed -e "s/^\.$/${shortpath}/"
    echo "${output}" | tail -n "$(($(echo "${output}" | wc -l)-1))"
  ) | less -EFSX
}

# Change sudo behaviour to preserve user profile
sudo() {
  if [[ "$*" == '-s' ]] || [[ "$*" == '-i' ]]; then
    # sudo -s invoked, replace it with login prompt
    command sudo -E bash -l
  elif [ -z "$1" ] || [[ "$1" == -* ]]; then
    # Some arguments passed to sudo, don't touch them
    command sudo "$@"
  else
    # No arguments passed to sudo, add -E
    command sudo -E "$@"
  fi
}

tmux() {
  if [ "$#" -ne 0 ]; then
    command "$(which tmux)" "$@"
  else
    local -r id="$(ps -p $$ -o tty= | sed -e 's/ *$//')"
    if [ -n "${id}" ]; then
      tmux attach -t "${id}" 2> /dev/null || tmux new -s "${id}"
    else
      tmux attach 2> /dev/null || tmux new
    fi
  fi
}

# ================================= ALIASES ====================================

alias dirs='dirs -v'
alias f='open -a Finder ./'
alias grep='grep --color'
alias ll='ls -lAhp'
alias lr='lstree'
alias mkdir='mkdir -pv'
alias numfiles='echo $(ls -1 | wc -l)'
alias prettyjson='python -m json.tool'
alias sudo='sudo '                    # With this aliases can be used with sudo

if [[ "$(uname -s)" == 'Darwin' ]]; then
  alias cask='brew cask'
  alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
fi

unset -f pathadd
unset BREW_PREFIX
