#!/bin/bash
while :
do
    echo "Starting watgbridge"
    sleep 20
    ./watgbridge &
    _pid=$!
    sleep 2h
    kill -9 $_pid
done
