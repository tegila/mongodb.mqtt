#!/bin/bash

# This script subscribes to a MQTT topic using mosquitto_sub.
# On each message received, you can execute whatever you want.

DEFAULTMQTT_HOST="b"
DEFAULTMQTT_PORT="1883"
DEFAULTMQTT_TOPIC_IN="/mongo/input/#"
DEFAULTDATABASE_NAME="openinterest"
DEFAULTDATABASE_HOST="b"

MQTT_HOST="${MQTT_HOST:-$DEFAULTMQTT_HOST}"
MQTT_PORT="${MQTT_PORT:-$DEFAULTMQTT_PORT}"
MQTT_TOPIC_IN="${MQTT_TOPIC_IN:-$DEFAULTMQTT_TOPIC_IN}"
printf "`date "+%Y-%m-%d %H:%M:%S"` "
echo $MQTT_HOST $MQTT_PORT $MQTT_TOPIC_IN 

DATABASE_NAME="${DATABASE_NAME:-$DEFAULTDATABASE_NAME}"
DATABASE_HOST="${DATABASE_HOST:-$DEFAULTDATABASE_HOST}"
printf "`date "+%Y-%m-%d %H:%M:%S"` "
echo $DATABASE_HOST $DATABASE_NAME

while true  # Keep an infinite loop to reconnect when connection lost/broker unavailable
do
    mosquitto_sub -v -q 2 -h ${MQTT_HOST} -p ${MQTT_PORT} -t ${MQTT_TOPIC_IN} | \
    while read -r payload
    do
        printf "`date "+%Y-%m-%d %H:%M:%S"` "
        echo "${payload}"
        IFS=' ' read -r -a array <<< "$payload"
        TOPIC=${array[0]}
        payload=${array[1]}
        IFS='/' read -r -a array <<< "$TOPIC"
        REPLY_TO=${array[3]}
        echo $REPLY_TO
        ANSWER=$(mongo --host ${DATABASE_HOST} ${DATABASE_NAME} --eval "${payload}" --quiet)
        echo $ANSWER
        #mongo --host b openinterest --eval "db.getCollection('openinterest').find({})" --quiet
        mosquitto_pub -h ${MQTT_HOST} -p ${MQTT_PORT} -t /mongo/output/${REPLY_TO} -m "${ANSWER}"
    done
    sleep 3  # Wait 3 seconds until reconnection
done # &  # Discomment the & to run in background (but you should rather run THIS script in background)
