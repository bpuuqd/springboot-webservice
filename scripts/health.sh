#!/usr/bin/env bash

ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname $ABSPATH)
source ${ABSDIR}/profile.sh
source ${ABSDIR}/switch.sh

IDLE_PORT=$(find_idle_port)

echo "> Health Check Start!"
echo "> IDLE_PORT: $IDLE_PORT"
echo "> curl -s http://localhost:$IDLE_PORT/profile "
sleep 10

for RETRY_COUNT in {1..10}
do
  RESPONSE=$(curl -s http://localhost:${IDLE_PORT}/profile)
  UP_COUNT=$(echo ${RESPONSE} | grep 'real' | wc -1)

  if [ ${UP_COUNT} -ge 1 ]
  then # $up_count >= 1 ("real" 문자열이 있는지 검증)
      echo "> Health check success"
      switch_proxy
      break
  else
      echo ">Not able to verify Health check response or not running "
      echo "> Health check: ${RESPONSE}"
  fi

  if[ ${RETRY_COUNT} -eq 10 ]
  then
    echo "> Health check fail"
    echo "> cancel connecting to Nginx and stop deploying"
    exit 1
  fi
  echo "> fail to connecting to Health check. retry... "
  sleep 10
done