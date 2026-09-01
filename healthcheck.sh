#!/bin/bash

check_service() {
    if systemctl is-active --quiet nginx; then
        echo "OK: nginx service is running."
    else
        echo "FAIL: nginx service is NOT running."
        exit 1
    fi
}

check_http() {
    if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200"; then
        echo "OK: nginx is responding with HTTP 200."
    else
        echo "FAIL: nginx did not respond with HTTP 200."
        exit 1
    fi
}

check_service
check_http

echo "Healthcheck passed."
