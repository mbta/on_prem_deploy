# 4. Only require 2FA on signin

Date: 2023-05-16

## Status

Accepted

## Context

When a user of the Linux VM uses `sudo`, there is a question about whether we
should require them to enter their TOTP 2FA code.

While it seems like this would add security, in practice it does not:

- If the TOTP secret is compromised, then an attacker can generate a code on demand anyways
- If a single TOTP code is compromised, then an attacker can reset the the TOTP secret after logging in

## Decision

`sudo` will not require entering a second factor.

## Consequences

Users will need to keep their TOTP secret secure, but that has always been the
case. We will also need to trust the other administrators on the server, as they
will also be able to view the TOTP secrets.
