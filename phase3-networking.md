# Phase 3 — Networking Troubleshooting

## Port Inspection
Used `ss -tulnp` to inspect listening ports and confirm which process owns
each one - e.g. `nginx` on port 80, `sshd` on port 22.

## Experiment: Service Down vs Port Closed
Manually stopped Nginx (`systemctl stop nginx`) and confirmed:
- Port 80 no longer appeared in `ss -tulnp` output.
- Both browser and `curl -v http://localhost` returned "Failed to connect" /
  "Connection refused".

This demonstrated that a port is only "open" while a process is actively
listening on it — not a fixed/reserved state.

## Error Pattern Reference
- **Connection refused / Failed to connect** → nothing is listening on that
  port (service down).
- **Connection timed out** → traffic is being blocked before reaching the
  service (firewall / Security Group issue).
- **404** → the service is up and responding, but the requested resource
  doesn't exist.

## Recovery
Restarted Nginx (`systemctl start nginx`), confirmed port 80 reappeared in
`ss -tulnp`, and validated recovery with `curl -v http://localhost`.


## DNS Resolution
Used `dig` to inspect DNS resolution behavior.

**Normal resolution** (`dig google.com`):
- Returned an `ANSWER SECTION` with multiple `A` records (IPv4 addresses)
  for the same domain a form of DNS round-robin, used for load
  distribution and resilience (if one server fails, other IPs still resolve
  and respond).
- TTL (Time To Live) indicates how long a resolver may cache the answer
  before querying again.

**Non-existent domain** (`dig <random-nonexistent-domain>`):
- No `ANSWER SECTION` was returned.
- Instead, an `AUTHORITY SECTION` with an `SOA` (Start of Authority) record
  appeared, and the header showed `status: NXDOMAIN` the standard DNS
  code indicating the domain does not exist at all.

**Reference:**
- Normal resolution → `ANSWER SECTION` with `A` records.
- Non-existent domain → `AUTHORITY SECTION` + `SOA` + `status: NXDOMAIN`.

## Simulating "Application Can't Reach Database"
Used `nc -zv` (Linux) and `Test-NetConnection` (Windows/PowerShell) to test
port connectivity from two different vantage points.

**From inside the server** (`nc -zv localhost 5432`):
- Immediate response: `Connection refused`.
- Meaning: the network path is fine, but nothing is listening on that port
  (e.g. database service down, or wrong port configured).

**From outside, over the internet** (`Test-NetConnection -Port 5432`):
- Slow response, ending in timeout (`TcpTestSucceeded: False`).
- Meaning: traffic never reached the service at all blocked upstream by
  the AWS Security Group (only ports 22 and 80 are allowed).

**Key takeaway:** the *speed and type* of failure is a diagnostic signal by
itself:
- Instant "connection refused" → service-level issue (nothing listening).
- Slow timeout → network/firewall-level issue (traffic blocked before
  reaching the service).