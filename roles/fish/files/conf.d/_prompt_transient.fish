# Workaround for repainting prompt before executing
# Reference: https://github.com/IlanCosman/tide/issues/85#issuecomment-1409875980

function reset-transient --on-event fish_postexec
    set -g TRANSIENT 0
end

function transient_execute
    if commandline --is-valid
        set --global TRANSIENT 1
        commandline --function repaint
    else if test "$(commandline -b)" = "" # fix empty enter
        set --global TRANSIENT 2
        commandline --function repaint
    else
        set --global TRANSIENT 0
    end
    commandline --function execute
end

bind -M default -m insert \r transient_execute
bind -M insert \r transient_execute
bind -M replace -m insert \r transient_execute
