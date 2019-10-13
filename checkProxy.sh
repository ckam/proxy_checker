#!/bin/bash

PROXYS='proxy.txt'
CHECK_GEOIP_URL='https://geoip-db.com/json/'
MAX_CONNECT=10
PING_COUNT=4
GOOD_ARR=()
FAIL_ARR=()
GOOD=0
FAIL=0

# COLORS #
RED='\033[1;31m'
GRN='\033[1;32m'
YEL='\033[1;33m'
BLU='\033[1;34m'
TUR='\033[1;36m'
WHT='\033[1;37m'
DEF='\033[0m'
# END OF COLORS #

# GET OPTIONS #
while getopts ":h:f:g:b:m:u:p:" OPTION
do
  case $OPTION in
    h)
      echo "Usage: $0 [-h - help] [-f <file> - file with proxy, default proxy.txt] [-g <file> - out file for good proxies] [-b <file> - out file for bad proxies] [-u <url> - url for check proxy, default $CHECK_URL] [-m <sec> - max connect time in second, default 10 sec] [-p <count> - max ping count for AVG time, default 4 count]"
      echo "proxy format: ip:port:username:password or ip:port"
      exit 0;;
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
    p)
      PING_COUNT="$OPTARG";;
  esac
done
# END OF GET OPTIONS #

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
  if [[ "${PROXY:0:1}" != "#" ]]
  then
    unset USER PASS
    IP=$(echo $PROXY | awk -F: '{print $1}')
    PORT=$(echo $PROXY | awk -F: '{print $2}')
    USER=$(echo $PROXY | awk -F: '{print $3}')
    PASS=$(echo $PROXY | awk -F: '{print $4}')
    PROXY_TYPE=$(echo $PROXY | awk -F: '{print $5}')

    # PROXY TYPE #
  	if [[  $PROXY_TYPE == "socks4" ]]
  	then
  		PROXY_TYPE="socks4"
  		PROXY_TYPE_COMMAND="--socks4 "
  	
  	elif [[ $PROXY_TYPE == "socks5" ]]
  	then
  		PROXY_TYPE="socks5"
  		PROXY_TYPE_COMMAND="--socks5 "
  	
  	elif [[ $PROXY_TYPE == "socks5-hostname" ]]
  	then
  		PROXY_TYPE="s5host"
  		PROXY_TYPE_COMMAND="--socks5-hostname "
  	
  	elif [[ $PROXY_TYPE == "https" ]]
  	then
  		PROXY_TYPE="https "
  		PROXY_TYPE_COMMAND="--proxy https://"
  	
  	else
  		PROXY_TYPE=" http "
  		PROXY_TYPE_COMMAND="--proxy http://"
  		
  	fi
  	# END OF PROXY TYPE #
    
    echo -ne "$IP\t$PORT\t$USER\t$PASS\t[$PROXY_TYPE] "
    
    if [[ $USER && $PASS ]]
    then
      GEOIP=$(curl -s -m $MAX_CONNECT $PROXY_TYPE_COMMAND$IP:$PORT -U $USER:$PASS $CHECK_GEOIP_URL$IP)
      CHECK=$?
    else
      GEOIP=$(curl -s -m $MAX_CONNECT $PROXY_TYPE_COMMAND$IP:$PORT $CHECK_GEOIP_URL$IP)
      CHECK=$?
    fi
    
    if [[ $CHECK -eq 0 ]]
    then
      echo -ne $GRN"good"$DEF" "$(echo $GEOIP | awk -F, '{print $2}' | awk -F: '{print $2}' | cut -d '"' -f 2)" "
      echo -e $WHT$(ping -c $PING_COUNT $IP | tail -1| awk '{print $4}' | cut -d '/' -f 2)$DEF
      GOOD=$(($GOOD+1))
      GOOD_ARR+=($PROXY)
    else  
      echo -e $RED"dead"$DEF
      FAIL=$(($FAIL+1))
      FAIL_ARR+=($PROXY)
    fi
  fi
done
# END OF CHECK PROXY #

# SAVE GOOD PROXY TO FILE #
if [[ $GOOD_FILE ]]
then
  echo -n > $GOOD_FILE
  echo ${GOOD_ARR[@]} | tr " " "\n" >> $GOOD_FILE
  echo -e $GRN"Good proxies save in $GOOD_FILE"$DEF
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

echo -e $TUR"all: $(($GOOD+$FAIL))"$DEF", "$GRN"Good proxy: $GOOD"$DEF", "$RED"bad proxy: $FAIL"$DEF

exit 0

