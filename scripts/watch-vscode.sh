#!/bin/bash
PROJECT_DIR="{{PROJECT_DIR}}"
WAS_RUNNING=false

while true; do
    if ps aux | grep -v grep | grep "code" | grep -q "$PROJECT_DIR"; then
        WAS_RUNNING=true
    else
        if [ "$WAS_RUNNING" = true ]; then
            sleep 2
            /usr/local/bin/gitShutPush.sh
            WAS_RUNNING=false
        fi
    fi
    sleep 5
done