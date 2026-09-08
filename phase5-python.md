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

## AWS Automation with boto3
Installed `boto3` and wrote `list-instances.py` to interact directly with
the AWS EC2 API from Python.

**Authentication:** used an IAM Role attached to the EC2 instance
(`AmazonEC2ReadOnlyAccess`) instead of hardcoded access keys following the
principle of least privilege (read-only, since the script only lists
resources) and avoiding credentials stored in files or code.

**Evolution:**
1. First version: listed all EC2 instances in the account regardless of
   state, using `describe_instances()`.
2. Second version: used a server-side filter
   (`Filters=[{"Name": "instance-state-name", "Values": ["running"]}]`) to
   return only running instances directly from the API more efficient
   than fetching everything and filtering in Python, especially at scale.

**Key takeaway:** cloud SDKs let you query and filter infrastructure state
programmatically the same kind of visibility that helps catch forgotten
resources (a common source of unexpected cloud costs) before they become a
billing surprise.