#!/bin/bash

LOG=/tmp/jupyter.log
echo "" > $LOG


check_jupyter() {
    if ps eax | grep -v grep | grep jupyter-lab; then
        echo "jupyter-lab is already running" | tee -a $LOG
        exit 0
    fi
}

run_jupyter() {
    nohup jupyter lab \
          --port=8888 \
          --no-browser \
          --allow-root \
          --ip=0.0.0.0 \
          --NotebookApp.token="" \
          --NotebookApp.password="" \
        &>1 | tee -a $LOG &
}

check_jupyter

run_jupyter

