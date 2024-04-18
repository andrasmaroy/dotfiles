function _prompt_jobs
    set --local stopped_jobs (count (jobs | awk '{print $3}' | grep stopped))
    set --local running_jobs (count (jobs | awk '{print $3}' | grep running))

    if test $stopped_jobs -gt 0 -o $running_jobs -gt 0
        set_color --bold white
        printf '[%sr/%ss] ' $running_jobs $stopped_jobs
        set_color normal
    end
end
