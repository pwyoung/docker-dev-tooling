#!/bin/bash

LOG=/tmp/start-jupyter.log
echo "" > $LOG

ARGS="--no-browser --allow-root --ip=0.0.0.0"
ARGS+=" --port=8888"
# Don't expose this except via ssh-tunnels
# ARGS+=" --NotebookApp.token='' --NotebookApp.password=''" # No creds
# ARGS+=" --NotebookApp.password='dev'"

run_jupyter() {
    if ps eax | grep -v grep | grep -iv defunct | grep jupyter-lab; then
        echo "jupyter-lab is already running" | tee -a $LOG
    else
        nohup jupyter lab $ARGS 2>&1 | tee -a $LOG &
    fi
}

show_token() {
    for i in $(seq 1 4); do
        TOKEN=$(jupyter notebook list | grep token | perl -pe 's/.*=(.*?) .*/$1/')
        if [ "$TOKEN" != "" ]; then
            echo "TOKEN=$TOKEN" | tee -a $LOG
            break
        fi
        sleep 1
    done
}

run_jupyter

show_token
