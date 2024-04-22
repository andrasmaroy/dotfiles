if status is-interactive

    # GNU ls colors
    set -gx LS_COLORS 'di=1;34:ln=1;36:so=1;35:pi=33;40:ex=1;32:bd=1;33;40:cd=1;33;40:su=30;43:sg=37;41:tw=37;44:ow=1;35'
    # BSD ls colors
    set -gx CLICOLOR 'Yes'
    set -gx LSCOLORS 'ExGxFxdaCxDADAadhbheFx'
    set -gx TREE_COLORS 'ln=36'

    set -gx LESS_TERMCAP_mb (set_color d75f00)

    if command -q bat
        set -gx BAT_THEME Tomorrow-Night-Eighties
    end
    fish_config theme choose 'Tomorrow Night Eighties'
end
