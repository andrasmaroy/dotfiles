if status is-interactive
    # Commands to run in interactive sessions can go here
    set fzf_diff_highlighter delta --paging=never --width=20

    set -U async_prompt_inherit_variables status pipestatus SHLVL CMD_DURATION fish_bind_mode VIRTUAL_ENV
    set -U async_prompt_functions fish_right_prompt _prompt_git _prompt_hostname _prompt_pwd _prompt_user _prompt_virtualenv
end
