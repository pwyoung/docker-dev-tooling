#!/bin/bash

LOG=/tmp/ssh.log
echo "" > $LOG

sudo service ssh start &> $LOG
