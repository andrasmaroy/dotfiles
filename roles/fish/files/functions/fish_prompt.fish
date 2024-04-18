function fish_prompt
    set --local exit_code $status  # save previous exit code

    _prompt_time

    _prompt_status $exit_code

    set --local njobs (count (jobs -p))
    if test "$njobs" -gt 0
        set_color --bold white
        echo -n "[$njobs] "
        set_color normal
    end

    _prompt_pwd
    echo -n "\$ "
end
