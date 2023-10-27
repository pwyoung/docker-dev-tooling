#!/bin/bash

LOG=/tmp/start-ssh.log
echo "" > $LOG

sudo service ssh start &> $LOG
