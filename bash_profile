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

if [ -f "${HOME}/.git-prompt.sh" ]; then
  source "${HOME}/.git-prompt.sh"
  export GIT_PS1_SHOWDIRTYSTATE=1
  export GIT_PS1_SHOWUNTRACKEDFILES=1
  export GIT_PS1_SHOWCOLORHINTS=1
  export GIT_PS1_SHOWUPSTREAM='auto'
fi

# Highlight the user name when logged in as root
if [[ "${USER}" == 'root' ]]; then
    userStyle="${RED}"
else
    userStyle="${RESET}"
fi;

# Highlight the hostname when connected via SSH
if [[ "${SSH_TTY}" ]]; then
    hostStyle="${BOLD}${RED}"
else
    hostStyle="${RESEST}"
fi;

# Prompt setup
PROMPT_COMMAND='__git_ps1 '                             # Git prompt
PROMPT_COMMAND+='"\[\033]0;\w\007\]'                    # Window title to CWD
PROMPT_COMMAND+='\t '                                   # Current time
PROMPT_COMMAND+='`if [ \$? = 0 ]; then echo \\\[\\\e[32m\\\][\$?]; else echo \\\[\\\e[31m\\\][\$?]; fi`'    # Exit code color coded
PROMPT_COMMAND+='\[${RESET}\] '
PROMPT_COMMAND+='\[${userStyle}\]\u'                    # Username
PROMPT_COMMAND+='\[${RESET}\]@'
PROMPT_COMMAND+='\[${hostStyle}\]\h:'                   # Hostname
PROMPT_COMMAND+='\[${RESET}${BOLD}\]$(sed "s:\([^/]\)[^/]*/:\1/:g" <<<$PWD)\[${RESET}\]'    # Working dir, abbreviated vim style
PROMPT_COMMAND+='$([[ -n "$VIRTUAL_ENV" ]] && echo " (\[${BLUE}\]${VIRTUAL_ENV##*/}\[${RESET}\])")' # Virtualenv
PROMPT_COMMAND+='\[${RESET}\]" '
PROMPT_COMMAND+='"\[${WHITE}\]\n\\\$\[${RESET}\] ";'    # $ in newline
export PROMPT_COMMAND
#export PS1='\t [$?] \u@\h:\w$(__git_ps1)\$ '

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

# Aliases
alias ll='ls -lAhp'
alias gg='git status -s'
alias gl='git log --graph --pretty=format:"%C(auto)%h %d %C(cyan)%an%C(reset) %s" $(git merge-base HEAD @{u})~3.. @{u}'
alias gla='git log --graph --decorate --oneline HEAD @{u}'
alias gd='git difftool -t vimdiff'
alias grep='grep --color=auto'
alias mkdir='mkdir -pv'
alias f='open -a Finder ./'
alias numFiles='echo $(ls -1 | wc -l)'
alias flushDNS='sudo discoveryutil mdnsflushcache;sudo discoveryutil udnsflushcaches'
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'
alias ds='docker-machine start dev; eval $(docker-machine env dev)'

