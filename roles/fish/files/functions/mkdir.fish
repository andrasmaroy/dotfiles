if command -q gmkdir
    function mkdir --wraps=gmkdir
        command gmkdir -pv $argv
    end
else
    function mkdir --wraps=mkdir
        command mkdir -pv $argv
    end
end
