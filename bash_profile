# ============================== BASH PROFILE ==================================
export PATH="/usr/local/sbin:${PATH}"

if [ -d "${HOME}/Git/github/depot_tools:${PATH}" ]; then
  export PATH="${HOME}/Git/github/depot_tools:${PATH}"
fi

if [ -d "$HOME/.bin" ]; then
  export PATH="${HOME}/.bin:${PATH}"
fi

# docker-machine
if [ -f '/Applications/VMware Fusion.app/Contents/Library/vmrun' ] \
     && '/Applications/VMware Fusion.app/Contents/Library/vmrun' list \
     | grep "${HOME}/.docker/machine/machines/dev/dev.vmx" &> /dev/null; then
  eval "$(docker-machine env dev)"
fi

if [ -d "${HOME}/.pumpkin" ]; then
  export PUMPKIN_HOME="${HOME}/.pumpkin"
fi

# Wrapper for python virtualenvs
if which brew &> /dev/null \
     && [ -f "$(brew --prefix)/bin/virtualenvwrapper.sh" ]; then
  source "$(brew --prefix)/bin/virtualenvwrapper.sh"
  export WORKON_HOME="${HOME}/.virtualenvs"
fi

# ============================ TERMINAL OPTIONS ================================

# Make vim the default editor.
export EDITOR='vim'

# Prefer US English and use UTF-8.
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Set colors
RESET="$(tput sgr0)"
BOLD="$(tput bold)"
BLACK="$(tput setaf 0)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
MAGENTA="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
WHITE="$(tput setaf 7)"
PURPLE="$(tput setaf 141)"
ORANGE="$(tput setaf 166)"

# Enable colors for tools
export CLICOLOR='Yes'
export GREP_OPTIONS='--color'
export LS_OPTIONS='--color=auto'
export LSCOLORS='ExGxFxdaCxDADAadhbheFx'
#export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD

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
elif [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
fi

# Git completion
if [ -f "${HOME}/.git-completion.bash" ]; then
  source "${HOME}/.git-completion.bash"
fi

# ============================== PROMPT SETUP ==================================

# Git prompt setup
if [ -f "${HOME}/.git-prompt.sh" ]; then
  source "${HOME}/.git-prompt.sh"
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

# Get CWD abbreviated VIm style
__abbrev_cwd() {
  p="${PWD#$HOME}"
  if [[ "${PWD}" != "${p}" ]]; then
    echo -n '~'
  fi
  sed 's:\([^/]\)[^/]*/:\1/:g' <<< "${p}"
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

# Put together to prompt
__prompt_command() {
  local EXIT_CODE="$(__return_code $?)"       # this line has to be the first
  local TITLEBAR="\033]0;$(__abbrev_cwd)\007"
  local TIME='\t'
  local USER="$(__user_style)\u${RESET}"
  local HOST="$(__host_style)\h${RESET}"
  local CWD="${BOLD}$(__abbrev_cwd)${RESET}"
  local VENV="$(__virtualenv_name)"
  local PROMPT="\n\[${WHITE}\]\$\[${RESET}\]"

  local PRE="${TITLEBAR}${TIME} [${EXIT_CODE}] ${USER}@${HOST}:${CWD} ${VENV}"
  local POST="${PROMPT} "

  if type -t __git_ps1 &> /dev/null; then
    __git_ps1 "${PRE}" "${POST}" '(%s)'
  else
    export PS1="${PRE}${POST}"
  fi
}

export PROMPT_COMMAND=__prompt_command

# ============================ HELPER FUNCTIONS ================================

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

# Get escape code for a character
escape() {
  printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u)
  # print a newline unless we’re piping the output to another program
  if [ -t 1 ]; then
    echo ""
  fi
}

# ================================= ALIASES ====================================

alias ll='ls -lAhp'
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'
alias gg='git status -s'
alias gl='git log --graph --pretty=format:"%C(auto)%h %d %C(cyan)%an%C(reset) %s" $(git merge-base HEAD @{u})~3.. @{u}'
alias gla='git log --graph --decorate --oneline HEAD @{u}'
alias gd='git difftool -t vimdiff'
alias mkdir='mkdir -pv'
alias f='open -a Finder ./'
alias numfiles='echo $(ls -1 | wc -l)'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias ds='docker-machine start dev && eval $(docker-machine env dev)'

