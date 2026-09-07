#!/bin/bash
# delete .logs files older than 7 days in a given directory
LOG_DIR=${1:-/var/log}
find "$LOG_DIR" -name ".log" -mtime +7 -exec rm {} \;
echo "Old logs removed from $LOG_DIR"