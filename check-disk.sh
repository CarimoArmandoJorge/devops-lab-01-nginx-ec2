#!/bin/bash
LIMITE=80
USO=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
echo "Current disk usage: ${USO}%"

if [ "$USO" -gt "$LIMITE" ]; then
	echo "WARNING: disk usage above ${LIMITE}%!"
else
	echo "Disk usage OK."
fi
