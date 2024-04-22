function lstree --wraps=ls --description 'Show directory tree in folder'
    set -l shortpath (basename (pwd))
    set -l output "$(tree -C -d --noreport $argv)"

    begin
        echo "$output" | head -n 1 | sed -e "s/\\./$shortpath/"
        echo "$output" | tail -n "$(math $(echo "$output" | wc -l) - 1)"
    end | less -EFRSX
end
