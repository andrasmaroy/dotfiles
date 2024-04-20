function _prompt_virtualenv
    if test -n "$VIRTUAL_ENV"
        echo -n -s '(' (set_color blue) (basename "$VIRTUAL_ENV") (set_color normal) ') '
    end
end
