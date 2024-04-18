function _prompt_jobs
    set --local njobs (count (jobs -p))
    if test "$njobs" -gt 0
        set_color --bold white
        echo -n "[$njobs] "
        set_color normal
    end
end
