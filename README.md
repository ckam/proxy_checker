# Simple bash proxy checker #
***

## Proxy format: ##
#### with authorization: ####

    ip:port:username:password
#### without authorization: ####

    ip:port

## Arguments: ##
* -h - help
* -t <type> - type of proxy (http - default, socks4, socks5, socks5-hostname (dns throught socks5))
* -f <file> - file with proxy, default proxy.txt
* -g <file> - out file for good proxies
* -b <file> - out file for bad proxies
* -u <url> - url for check, default "https://api.ipify.org?format=json"
* -m <sec> - max connect time in seconds, default 10 sec

***
### Example: ###
    ./checkProxy.sh -f proxy -t socks5 -m 5 -g good

***
