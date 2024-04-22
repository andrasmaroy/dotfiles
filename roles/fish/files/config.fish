if status is-interactive
    # Commands to run in interactive sessions can go here
    set fzf_diff_highlighter delta --paging=never --width=20

    set -U async_prompt_inherit_variables status pipestatus SHLVL CMD_DURATION fish_bind_mode VIRTUAL_ENV
    set -U async_prompt_functions fish_right_prompt _prompt_git _prompt_hostname _prompt_pwd _prompt_user _prompt_virtualenv

    if command -q brew
        set -gx HOMEBREW_NO_GITHUB_API '1'
        set -gx HOMEBREW_NO_INSTALL_UPGRADE '1'
    end

    if test (uname -s) = 'Darwin'
        set -gx XDG_CACHE_HOME "$HOME/Library/Caches/org.freedesktop"
    end

    # Make vim the default editor.
    set -gx EDITOR 'vim'

    # Prefer US English and use UTF-8.
    set -gx LANG 'en_US.UTF-8'
    set -gx LC_ALL 'en_US.UTF-8'

    fish_add_path '/usr/local/sbin'
    fish_add_path "$HOME/.bin"
    fish_add_path "$HOME/.bin/$(uname -s)"

    # A setting that does its best to keep ssh connections from freezing
    set -gx AUTOSSH_POLL '30'
    if test "$SSH_CONNECTION" != ""
        fish_add_path -g "$HOME/.bin/remote_utils"
    end
end
