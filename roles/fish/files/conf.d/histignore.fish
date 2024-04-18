function histignore --on-event fish_prompt # or maybe fish_preexec, see function --help
    echo 'all' | history --delete --prefix pwd ls ll history exit bg fg clear > /dev/null
end
