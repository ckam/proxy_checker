# Simple bash proxy checker #
***

## Arguments: ##
* -h - help
* -t <type> - type of proxy (http - default, socks4, socks5, socks5-hostname (dns throught socks5))
* -f <file> - file with proxy, default proxy.txt
* -g <file> - out file for good proxies
* -b <file> - out file for bad proxies
* -m <sec> - max connect time in seconds, default 10 sec

***
### Example: ###
    ./checkProxy.sh -f proxy -t socks5 -m 5 -g good

***
