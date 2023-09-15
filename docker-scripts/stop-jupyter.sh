#!/bin/bash

LOG=/tmp/jupyter.log

PID=$(lsof -i :8888 | grep LISTEN | awk '{print $2}')

if [ "$PID" != "" ]; then
    echo "Killing jupyter lab with PID=$PID"
    # We'll get a zombie...
    sudo kill -15 $PID
    sudo kill -9 $PID
fi
