function _prompt_symbol
    if test "$(id -u -n)" = "root"
        printf '\n# '
    else
        printf '\n$ '
    end
end
