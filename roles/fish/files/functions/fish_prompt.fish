function fish_prompt
    set --local exit_code $status  # save previous exit code

    _prompt_time
    _prompt_status $exit_code
    _prompt_jobs
    _prompt_pwd
    echo -n "\$ "
end
