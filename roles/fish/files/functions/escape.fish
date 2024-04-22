function escape \
    --description 'Print escape sequence for a given character' \
    --argument-names char

    printf "\\\\x%s" "$(printf '%s' "$argv" | xxd -p -c1 -u)"
end
