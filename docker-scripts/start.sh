#!/bin/bash

LOG=/tmp/start.log
echo "" > $LOG

/start-ssh.sh

/start-jupyter.sh
