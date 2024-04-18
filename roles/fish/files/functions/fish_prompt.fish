function fish_prompt
    echo -n "$(set_color --bold white)$_prompt_time $(set_color normal)"

    echo "$(set_color --bold white)$_prompt_pwd$(set_color normal)"
    echo -n "\$ "
end
