function _prompt_pwd --on-variable PWD
    set --local git_root (command git --no-optional-locks rev-parse --show-toplevel 2>/dev/null)

    if test -n $git_root
        set --local git_root_shortened (prompt_pwd "$git_root")
        set --local git_root_placeholder (prompt_pwd -D 0 "$git_root")
        set --local pwd (prompt_pwd)

        if test $pwd != $git_root_shortened
            set --global _prompt_pwd (string replace -- "$git_root_placeholder" "$git_root_shortened" "$pwd")
        else
            set --global _prompt_pwd "$pwd"
        end
    else
        set --global _prompt_pwd (prompt_pwd)
    end
end
