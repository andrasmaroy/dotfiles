function fe --description 'Fuzzy find files to edit'
    set -fx fzf_fd_opts --hidden --follow --exclude '.git' --type f
    set -fx fzf_directory_opts --select-1 --exit-0 --query=$argv[1] --preview='' --layout=default --prompt='> '
    _fzf_search_directory
    set -f files $(commandline --tokenize)
    if test -n "$files"
        commandline -br "vim $files"
        commandline --function execute
    else
        return 1
    end
end
