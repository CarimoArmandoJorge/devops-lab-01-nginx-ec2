#!/usr/bin/env python3
import requests
import sys

URL = "http://localhost"

def check_http(url):
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            print(f"OK: {url} responded with status 200.")
            return True
        else:
            print(f"FAIL: {url} responded with status {response.status_code}.")
            return False
    except requests.exceptions.RequestException as e:
        print(f"FAIL: could not reach {url}. Error: {e}")
        return False

if __name__ == "__main__":
    success = check_http(URL)
    sys.exit(0 if success else 1)
