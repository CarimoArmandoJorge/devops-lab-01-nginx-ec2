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