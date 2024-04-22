if test (uname -s) = 'Darwin'
    function f --description 'Open Finder in the specified folder'
        if test (count $argv) -eq 0
            open -a Finder .
        else
            open -a Finder $argv
        end
    end
end
