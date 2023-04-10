# 3. Use Ansible for configuration

Date: 2023-04-10

## Status

Accepted

Amends [2. Use CloudInit for basic Linux configuration](0002-use-cloudinit-for-basic-linux-configuration.md)

## Context

As the Linux configuration becomes more complicated, we need a way to be able to
express more complicated configurations, as well as ensure a VM is kept
up-to-date with configuration changes.

## Decision

[Ansible][ansible] is "an IT automation tool." Through playbooks, modules, and roles, it provides a way to either push configuration up to a server, or have a server pull down the configuration. From there, the server can apply the configuration to ensure that it is in a known state.

Cloud-init can point at an Ansible configuration, so we will use that to point the blank VM at the relevant Ansible configuration. From there, Ansible will apply the configuration describe in this or another repository.

## Consequences

What becomes easier or more difficult to do and any risks introduced by the change that will need to be mitigated.

[ansible]: https://docs.ansible.com/ansible/latest/index.html
