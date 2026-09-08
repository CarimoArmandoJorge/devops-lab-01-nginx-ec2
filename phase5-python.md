# Phase 5 - Python for Automation

## HTTP Healthcheck Script
Rewrote the Bash healthcheck logic in Python (`healthcheck.py`), using the
`requests` library and a virtual environment (`venv`) to isolate
dependencies.

```python
try:
    response = requests.get(url, timeout=5)
    ...
except requests.exceptions.RequestException as e:
    print(f"FAIL: could not reach {url}. Error: {e}")
    return False
```

**Key difference from Bash:** unlike `curl`, which always returns an HTTP
status code even on failure, `requests.get()` raises an exception when the
server is completely unreachable (DNS failure, connection refused, timeout)
, no response object is ever returned. `try/except` catches that exception
and turns it into a controlled failure (`False`, exit code 1) instead of
crashing the script.

**Verified end-to-end:** stopped Nginx, confirmed the script caught the
exception and returned exit code 1; restarted Nginx and confirmed recovery
with exit code 0, same behavior as the Bash version, implemented with
Python's exception handling model instead of shell exit codes.