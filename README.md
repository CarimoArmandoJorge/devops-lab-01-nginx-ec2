
# DevOps Lab 01 — Nginx on AWS EC2 with systemd Resilience


## Objective

Provision a Linux server on AWS, install and configure a web server (Nginx),
and validate that it survives a full server reboot without manual intervention.

## Architecture
```
Internet → Security Group (port 22, 80) → EC2 Instance (Ubuntu 24.04)
                                              └── Nginx (managed by systemd)
```


## What I Did
1. Provisioned an EC2 instance (Ubuntu Server 24.04, t3.micro, free tier).
2. Connected to the instance via SSH using a private key pair.
3. Performed basic server diagnostics (`whoami`, `pwd`, `ls -la`, `df -h`, `top`)
   to understand user context, filesystem permissions, disk usage, and running processes.
4. Installed Nginx via `apt`.
5. Verified the service was active using `systemctl status`.
6. Confirmed Nginx was enabled to start automatically on boot (`systemctl is-enabled`).
7. Updated the AWS Security Group to allow inbound HTTP traffic (port 80).
8. Rebooted the instance (`sudo reboot`) to test resilience.
9. Reconnected after reboot and verified Nginx was serving traffic again
   with zero manual intervention.


## Commands Used
```bash
sudo apt update
sudo apt install nginx -y
sudo systemctl status nginx
sudo systemctl is-enabled nginx
sudo reboot
```

## Result
Nginx served the default welcome page both before and after a full instance
reboot, confirming the service was correctly configured for resilience via
systemd — no manual restart was required.

## Challenges & Troubleshooting
- Initial SSH connection failed on Windows PowerShell (`ssh` not recognized) —
  the OpenSSH client was reported as installed but the executable was not on
  the system PATH. Resolved by connecting through Git Bash instead, which
  ships with a working SSH client.
- Had to update the AWS Security Group to open port 80, since only port 22
  (SSH) was allowed by default the browser request would otherwise hang.

## What I Learned
- Linux permissions model (owner/group/other, `rwx`)
- Basic server diagnostics workflow (who am I, where am I, disk, processes)
- Managing services with `systemd`
- AWS Security Groups as a network firewall layer
- Difference between stopping and terminating an EC2 instance (cost implications)

## Bonus: Bash Automation
Added `check-disk.sh`, a script that checks root disk usage and alerts
when usage exceeds a defined threshold.

**Evolution of the script:**
1. First version: printed raw disk usage with `df -h /`.
2. Bug found and fixed: initial script failed with `df-h: command not found`
   due to a missing space between `df` and `-h`. This highlighted how Bash
   treats commands as exact strings a single missing space breaks execution.
3. Second version: added variables and a conditional to turn the script into
   a real monitoring check it now extracts the disk usage percentage with
   `awk`, stores it in a variable, and compares it against a threshold using
   an `if` statement, printing a warning only when usage is too high.

```bash
LIMIT=80
USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

if [ "$USAGE" -gt "$LIMIT" ]; then
    echo "WARNING: disk usage above ${LIMIT}%!"
else
    echo "Disk usage OK."
fi
```

## Bonus: Healthcheck Script
Added `healthcheck.sh`, which verifies both that the Nginx service is
running and that it responds with HTTP 200 using functions and exit codes
so the script can be consumed by other automation (e.g. CI/CD or monitoring).

**Test performed:** manually stopped Nginx (`systemctl stop nginx`) to confirm
the script correctly detected the failure, printed `FAIL`, and returned a
non-zero exit code (1). Restarted the service and confirmed recovery
(exit code 0).

**Concepts practiced:**
- Bash functions for reusable logic;
- Exit codes (`0` = success, non-zero = failure) as the standard way scripts communicate status to other automation;
- `curl` for HTTP-level health verification (not just process status).

## Bonus: Deployment Automation
Added `deploy.sh`, which automates a full deployment cycle: copying a new
version of the site, reloading Nginx, and validating success by running
`healthcheck.sh` automatically.

**Key practice: `set -e`** ensures the script stops immediately if any
step fails, instead of silently continuing with a broken deployment. This
mirrors real-world CI/CD pipeline behavior, where a single failed step
should halt the process rather than proceed silently.

**Verified end-to-end:** ran the script, confirmed all 3 steps succeeded,
and visually validated the new page was live in the browser.

**Concepts practiced:**
- `set -e` for fail-fast automation
- Chaining previously built scripts (`healthcheck.sh`) into a larger workflow
- Basic deployment sequence: deploy → reload → validate