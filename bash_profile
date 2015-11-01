export PATH="$HOME/Git/cms/depot_tools:/usr/local/sbin:$PATH"
if [ -d ~/.bin ]; then
    export PATH="$HOME/.bin:$PATH"
fi

# docker-machine
if /Applications/VMware\ Fusion.app/Contents/Library/vmrun list | grep "/Users/amaroy/.docker/machine/machines/dev/dev.vmx" &> /dev/null; then
    eval "$(docker-machine env dev)"
fi

export PUMPKIN_HOME="$HOME/.pumpkin"

# Wrapper for python virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
export WORKON_HOME="$HOME/.virtualenvs"

# Git completion
source ~/.git-completion.bash
source ~/.git-prompt.sh

# Make vim the default editor.
export EDITOR='vim';

# Prefer US English and use UTF-8.
export LANG='en_US.UTF-8';
export LC_ALL='en_US.UTF-8';

# Set colors
if tput setaf 1 &> /dev/null; then
    tput sgr0; # reset colors
    bold=$(tput bold);
    reset=$(tput sgr0);
    black=$(tput setaf 0);
    blue=$(tput setaf 4);
    cyan=$(tput setaf 6);
    green=$(tput setaf 2);
    orange=$(tput setaf 166);
    purple=$(tput setaf 125);
    red=$(tput setaf 1);
    violet=$(tput setaf 61);
    white=$(tput setaf 7);
    yellow=$(tput setaf 4);
else
    bold='';
    reset="\e[0m";
    black="\e[1;30m";
    blue="\e[1;34m";
    cyan="\e[1;36m";
    green="\e[1;32m";
    orange="\e[1;33m";
    purple="\e[1;35m";
    red="\e[1;31m";
    violet="\e[1;35m";
    white="\e[1;37m";
    yellow="\e[1;33m";
fi;

# Set ls colors
export LS_OPTIONS='--color=auto'
export CLICOLOR='Yes'
export LSCOLORS=ExGxFxdaCxDADAadhbheFx
#export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD

# Highlight section titles in manual pages.
export LESS_TERMCAP_md="${orange}";

# Add tab completion for many Bash commands
if which brew > /dev/null && [ -f "$(brew --prefix)/etc/bash_completion" ]; then
    source "$(brew --prefix)/etc/bash_completion";
elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Highlight the user name when logged in as root
if [[ "${USER}" == "root" ]]; then
    userStyle="${red}";
else
    userStyle="${reset}";
fi;

# Highlight the hostname when connected via SSH
if [[ "${SSH_TTY}" ]]; then
    hostStyle="${bold}${red}";
else
    hostStyle="${reset}";
fi;

# Git prompt setup
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWCOLORHINTS=1
GIT_PS1_SHOWUPSTREAM="auto"

# Prompt setup
PROMPT_COMMAND='__git_ps1 '                             # Git prompt
PROMPT_COMMAND+='"\[\033]0;\w\007\]'                    # Window title to CWD
PROMPT_COMMAND+='\t '                                   # Current time
PROMPT_COMMAND+='`if [ \$? = 0 ]; then echo \\\[\\\e[32m\\\][\$?]; else echo \\\[\\\e[31m\\\][\$?]; fi`'    # Exit code color coded
PROMPT_COMMAND+='\[${reset}\] '
PROMPT_COMMAND+='\[${userStyle}\]\u'                    # Username
PROMPT_COMMAND+='\[${reset}\]@'
PROMPT_COMMAND+='\[${hostStyle}\]\h:'                   # Hostname
PROMPT_COMMAND+='\[${reset}${bold}\]$(p="${PWD#${HOME}}"; [ "${PWD}" != "${p}" ] && printf "~";IFS=/; for q in ${p:1}; do printf /${q:0:1}; done; printf "${q:1}")'
PROMPT_COMMAND+='\[${reset}\]" '
PROMPT_COMMAND+='"\[${white}\]\n\\\$\[${reset}\] ";'    # $ in newline
export PROMPT_COMMAND
#export PS1='\t [$?] \u@\h:\w$(__git_ps1)\$ '

# Bash completion
if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi

# History
# put timestamps in my bash history
export HISTTIMEFORMAT='%F %T '
# don't put duplicate commands into the history
export HISTCONTROL=ignoredups
# record only the most recent duplicated command (see above)
export HISTCONTROL=ignoreboth
# don't record these commands in the history; who cares about ls?
export HISTIGNORE='pwd:ls:history:'

# a setting that does its best to keep ssh connections from freezing
export AUTOSSH_POLL=30

# Extract:  Extract most know archives with one command
function extract () {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
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

# Get escape code for a character
function escape() {
    printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u);
    # print a newline unless we’re piping the output to another program
    if [ -t 1 ]; then
        echo ""; # newline
    fi;
}

