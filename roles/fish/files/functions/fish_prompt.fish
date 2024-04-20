function fish_prompt
end # In case this file gets loaded non-interactively
status is-interactive || exit

function fish_prompt
    set --local exit_code $status  # save previous exit code

    _prompt_time
    _prompt_status $exit_code
    _prompt_jobs
    _prompt_virtualenv
    _prompt_user
    _prompt_hostname
    _prompt_pwd
    _prompt_git
    _prompt_symbol
end
