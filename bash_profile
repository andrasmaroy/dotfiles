# ============================== BASH PROFILE ==================================
export PATH="/usr/local/sbin:${PATH}"

if [ -d "${HOME}/Git/github/depot_tools" ]; then
  export PATH="${HOME}/Git/github/depot_tools:${PATH}"
fi

if [ -d "$HOME/.bin" ]; then
  export PATH="${HOME}/.bin:${PATH}"
fi

if [ -d "${HOME}/.pumpkin" ]; then
  export PUMPKIN_HOME="${HOME}/.pumpkin"
fi

# Wrapper for python virtualenvs
if which brew &> /dev/null \
     && [ -f "$(brew --prefix)/bin/virtualenvwrapper.sh" ]; then
  source "$(brew --prefix)/bin/virtualenvwrapper.sh"
  export WORKON_HOME="${HOME}/.virtualenvs"
elif [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
  source /usr/local/bin/virtualenvwrapper.sh
  export WORKON_HOME="${HOME}/.virtualenvs"
fi

# Android stuff
if which brew &> /dev/null && [ -d "$(brew --prefix)/Cellar/android-ndk-r10e/r10e" ]; then
  export ANDROID_NDK="$(brew --prefix)/Cellar/android-ndk-r10e/r10e"
  export NDK_HOME="$(brew --prefix)/Cellar/android-ndk-r10e/r10e"
fi
if which brew &> /dev/null && [ -d "$(brew --prefix)/Cellar/android-sdk/22.0.5_1" ]; then
  export ANDROID_HOME="$(brew --prefix)/Cellar/android-sdk/22.0.5_1"
  export PATH="$ANDROID_HOME/platform-tools:$PATH"
  export PATH="$ANDROID_HOME/tools:$PATH"
fi

# RBEnv
if which rbenv > /dev/null; then
  eval "$(rbenv init -)"
fi

# Kubernetes
if which kubectl &> /dev/null; then
  for file in $(find ~/.kube -name "config-*"); do
    export KUBECONFIG="${file}:${KUBECONFIG}"
  done
fi

if which brew &> /dev/null; then
  export HOMEBREW_NO_GITHUB_API=1
fi

if [ -z "${LC_LOGINUSER}" ]; then
  export LC_LOGINUSER=$(logname)
  export LC_LOGINHOST=$(hostname)
fi

# ============================ TERMINAL OPTIONS ================================

# Make vim the default editor.
export EDITOR='vim'

# Prefer US English and use UTF-8.
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Set colors
source ~/.bash_colors

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
if which brew > /dev/null && [ -f "$(brew --prefix)/etc/bash_completion" ]; then
  source "$(brew --prefix)/etc/bash_completion"
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

# Color the given return code
__return_code() {
  if [ "$1" -eq 0 ]; then
    echo -n "${GREEN}"
  else
    echo -n "${RED}"
  fi
  echo "${1}${RESET}"
}

# Highlight the user name when logged in as root
__user_style() {
  if [[ "${USER}" == 'root' ]]; then
    echo "${RED}"
  fi
}

# Highlight the hostname when connected via SSH
__host_style() {
  if [[ -n "${SSH_TTY}" ]]; then
    echo "${BOLD}${RED}"
  fi
}

# Get current python virtualenv name
__virtualenv_name() {
  if [[ -n "${VIRTUAL_ENV}" ]]; then
    echo "(${BLUE}${VIRTUAL_ENV##*/}${RESET}) "
  fi
}

__jobs_count() {
  local stopped=$(jobs -sp | wc -l | grep -Eo "[0-9]+")
  local running=$(jobs -rp | wc -l | grep -Eo "[0-9]+")
  if [ $stopped -ne 0 ] || [ $running -ne 0 ]; then
    echo "[${running}r/${stopped}s] "
  fi
}

# Put together to prompt
__prompt_command() {
  local EXIT_CODE="$(__return_code $?)"       # this line has to be the first
  local TITLEBAR="\033]0;$(abbrev-path "${PWD}")\007"
  local  TIME='\t'
  if [ "${USER}" != "${LC_LOGINUSER}" ]; then
    local _USER="$(__user_style)\u${RESET}"
  fi
  if [ "${HOSTNAME}" != "${LC_LOGINHOST}" ]; then
    local HOST="$(__host_style)\h${RESET}"
  fi
  local CWD="${BOLD}$(abbrev-path "${PWD}")${RESET}"
  local JOBS="${BOLD}$(__jobs_count)${RESET}"
  local VENV="$(__virtualenv_name)"
  # $ color is set by inputrc editing mode, only reset
  local PROMPT="\n\\\$\[${RESET}\]"

  local PRE="${TITLEBAR}${TIME} [${EXIT_CODE}] ${JOBS}${VENV}${_USER}@${HOST}:${CWD} "
  local POST="${PROMPT} "

  if type -t __git_ps1 &> /dev/null; then
    __git_ps1 "${PRE}" "${POST}" '(%s)'
  else
    export PS1="${PRE}${POST}"
  fi
}

export PROMPT_COMMAND=__prompt_command

# ============================ HELPER FUNCTIONS ================================

# Abbreviate given path Vim style
abbrev-path() {
  p="${1#$HOME}"
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
  printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u)
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
  local -r output=$(tree -C -d --noreport "$@")

  (
    echo "${output}" | head -n 1 | sed -e "s/^\.$/${shortpath}/"
    echo "${output}" | tail -n $(($(echo "${output}" | wc -l)-1))
  ) | less -EFSX
}

# Change sudo behaviour to preserve user profile
sudo() {
  if [[ "$@" == '-s' ]] || [[ "$@" == '-i' ]]; then
    # sudo -s invoked, replace it with login prompt
    command sudo -E /bin/bash -l
  elif [ -z "$1" ] || [[ "$1" == -* ]]; then
    # Some arguments passed to sudo, don't touch them
    command sudo "$@"
  else
    # No arguments passed to sudo, add -E
    command sudo -E "$@"
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
  alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
fi

