function fish_right_prompt
    if test $CMD_DURATION -ge 1000
        set --local secs (math --scale=1 $CMD_DURATION/1000 % 60)
        set --local mins (math --scale=0 $CMD_DURATION/60000 % 60)
        set --local hours (math --scale=0 $CMD_DURATION/3600000)

        set --local duration

        test $hours -gt 0 && set --local --append duration $hours"h"
        test $mins -gt 0 && set --local --append duration $mins"m"
        test $secs -gt 0 && set --local --append duration $secs"s"

        echo $duration
    end
end
