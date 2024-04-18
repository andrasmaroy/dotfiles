function fish_prompt
    set --local exit_code $status  # save previous exit code

    echo -n "$(set_color --bold white)$_prompt_time $(set_color normal)"

    if test $exit_code -ne 0 -a $exit_code -ne 146
        echo -n "[$(set_color red)$exit_code$(set_color normal)] "
    end

    set --local njobs (count (jobs -p))
    if test "$njobs" -gt 0
        set_color --bold white
        echo -n "[$njobs] "
        set_color normal
    end

    echo "$(set_color --bold white)$_prompt_pwd$(set_color normal)"
    echo -n "\$ "
end
