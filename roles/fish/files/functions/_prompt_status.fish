function _prompt_status \
    --argument-names exit_code

    if test $exit_code -ne 0 -a $exit_code -ne 146
        echo -n "[$(set_color red)$exit_code$(set_color normal)] "
    end
end
