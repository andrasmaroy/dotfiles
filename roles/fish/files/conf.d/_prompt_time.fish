function _prompt_time --on-event fish_preexec --on-event fish_prompt
    set --global _prompt_time $(date '+%T')
end
