function extract \
    --description 'Extract the given file' \
    --argument-names target

    if test -f $target
        switch $target
            case '*.tar.bz2'
                tar xjf "$target"
            case '*.tar.gz'
                tar xzf "$target"
            case '*.bz2'
                bunzip2 "$target"
            case '*.rar'
                unrar e "$target"
            case '*.gz'
                gunzip "$target"
            case '*.tar'
                tar xf "$target"
            case '*.tbz2'
                tar xjf "$target"
            case '*.tgz'
                tar xzf "$target"
            case '*.zip'
                unzip "$target"
            case '*.Z'
                uncompress "$target"
            case '*'
                echo "'$target' cannot be extracted via extract()"
        end
    else
        echo "'$target' is not a valid file"
    end
end
