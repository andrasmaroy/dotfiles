if test (uname -s) = 'Darwin'
    function flushdns --description 'Flush OS DNS cache'
        sudo dscacheutil -flushcache
        sudo killall -HUP mDNSResponder
    end
end
