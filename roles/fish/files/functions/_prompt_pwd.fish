function _prompt_pwd
    set --local git_root (command git --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
    set --function pwd (prompt_pwd)

    if test -n $git_root
        set --local git_root_shortened (prompt_pwd "$git_root")
        set --local git_root_placeholder (prompt_pwd -D 0 "$git_root")

        if test $pwd != $git_root_shortened
            set --function pwd (string replace -- "$git_root_placeholder" "$git_root_shortened" "$pwd")
        end
    end
    echo -n "$(set_color --bold white)$pwd$(set_color normal) "
end
