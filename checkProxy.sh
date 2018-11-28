#!/bin/bash

PROXYS='proxy.txt'
PROXY_TYPE='http'
CHECK_URL='https://api.ipify.org?format=json'
MAX_CONNECT=10
GOOD_ARR=()
FAIL_ARR=()
GOOD=0
FAIL=0

# COLORS #
RED='\033[1;31m'
BLUE='\033[1;34m'
TUR='\033[1;36m'
YEL='\033[1;33m'
DEF='\033[0m'
# END OF COLORS #

# GET OPTIONS #
while getopts ":ht:f:g:b:m:u:" OPTION
do
  case $OPTION in
    h)
      echo "Usage: $0 [-h - help] [-t <type> - type of proxy (http - default, socks4, socks5, socks5-hostname (dns throught socks5))] [-f <file> - file with proxy, default proxy.txt] [-g <file> - out file for good proxies] [-b <file> - out file for bad proxies] [-u <url> - url for check proxy, default $CHECK_URL] [-m <sec> - max connect time in second, default 10 sec]"
      echo "proxy format: ip:port:username:password or ip:port"
      exit 0;;
    t)
      PROXY_TYPE="$OPTARG";;
    f)
      PROXYS="$OPTARG";;
    g)
      GOOD_FILE="$OPTARG";;
    b)
      FAIL_FILE="$OPTARG";;
    u)
      CHECK_URL="$OPTARG";;
    m)
      MAX_CONNECT="$OPTARG";;
  esac
done
# END OF GET OPTIONS #

# PROXY TYPE #
if [[ $PROXY_TYPE == "http" ]]
then
  PROXY_TYPE_COMMAND="--proxy"
elif [[  $PROXY_TYPE == "socks4" ]]
then
  PROXY_TYPE_COMMAND="--socks4"
elif [[ $PROXY_TYPE == "socks5" ]]
then
  PROXY_TYPE_COMMAND="--socks5"
elif [[ $PROXY_TYPE == "socks5-hostname" ]]
then
  PROXY_TYPE_COMMAND="--socks5-hostname"
else
  echo -e $RED"Unknown type proxy. Exit"$DEF
  exit 1
fi
# END OF PROXY TYPE #

# CHECK CURL IF EXIST #
if ! which curl > /dev/null
then
  echo -e $RED"curl not found"$DEF
  exit 1
fi
# END OF CHECK CURL IF EXIST #

# CHECK FILE WITH PROXY IF EXIST #
if ! [ -f $PROXYS > /dev/null ]
then
  echo -e $RED"File with proxy not found ($PROXYS)"$DEF
  exit 1
fi
# END OF CHECK FILE WITH PROXY IF EXIST #

# CHECK MAX TIME CONNECT #
RE='^[0-9]+$'
if ! [[ $MAX_CONNECT =~ $RE ]]
then
  echo -e $RED"Max connect - invalid format"$DEF
  exit 1
fi
# END OF CHECK MAX TIME CONNECT#

# CHECK PROXY #
for PROXY in $(<$PROXYS)
do
  unset USER PASS
  IP=$(echo $PROXY | awk -F: '{print $1}')
  PORT=$(echo $PROXY | awk -F: '{print $2}')
  USER=$(echo $PROXY | awk -F: '{print $3}')
  PASS=$(echo $PROXY | awk -F: '{print $4}')
  
  if [[ $USER && $PASS ]]
  then
    curl -s -m $MAX_CONNECT $PROXY_TYPE_COMMAND $IP:$PORT -U $USER:$PASS $CHECK_URL > /dev/null
    CHECK=$?
  else
    curl -s -m $MAX_CONNECT $PROXY_TYPE_COMMAND $IP:$PORT $CHECK_URL > /dev/null
    CHECK=$?
  fi
  
  if [[ $CHECK -eq 0 ]]
  then
    echo -e $TUR"$PROXY is good"$DEF
    GOOD=$(($GOOD+1))
    GOOD_ARR+=($PROXY)
  else  
    echo -e $RED"$PROXY is dead"$DEF
    FAIL=$(($FAIL+1))
    FAIL_ARR+=($PROXY)
  fi
done
# END OF CHECK PROXY #

# SAVE GOOD PROXY TO FILE #
if [[ $GOOD_FILE ]]
then
  echo -n > $GOOD_FILE
  echo ${GOOD_ARR[@]} | tr " " "\n" >> $GOOD_FILE
  echo -e $TUR"Good proxies save in $GOOD_FILE"$DEF
fi
# ENF OF SAVE GOOD PROXY TO FILE #

# SAVE FAIL PROXY TO FILE #
if [[ $FAIL_FILE ]]
then
  echo -n > $FAIL_FILE
  echo ${FAIL_ARR[@]} | tr " " "\n" >> $FAIL_FILE
  echo -e $RED"Bad proxies save in $FAIL_FILE"$DEF
fi
# END OF SAVE FAIL PROXY TO FILE #

echo -e $BLUE"Good proxy: $GOOD$DEF,$RED bad proxy: $FAIL$DEF,$TUR all: $(($GOOD+$FAIL))"$DEF

exit 0
