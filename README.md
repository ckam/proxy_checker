# Simple bash proxy checker #
***

## Proxy format (in text file): ##
#### with authorization: ####

    ip:port:username:password:type_proxy
#### without authorization: ####

    ip:port

## Arguments: ##
* -h - help
* -f <file> - file with proxy, default proxy.txt
* -g <file> - out file for good proxies
* -b <file> - out file for bad proxies
* -u <url> - url for check, default "https://api.ipify.org?format=json"
* -m <sec> - max connect time in seconds, default 10 sec

***
### Example: ###
    ./checkProxy.sh -f proxy -m 5 -g good

***