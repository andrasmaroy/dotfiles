if command -q bat
    function cat --wraps=bat
        command bat $argv
    end
end
