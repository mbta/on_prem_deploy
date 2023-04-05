# 2. Use CloudInit for basic Linux configuration

Date: 2023-04-05

## Status

Accepted

## Context

We need a way to provide a Linux image to ITD to run in the VMware environment,
along with the relevant configuration.

## Decision

[Cloud-init][cloud-init] is "the *industry standard* multi-distribution method
for cross-platform cloud instance initialization." In particular, it is
supported natively by Ubuntu's cloud images. It allows specifying the
configuration for the image as [VMware properties][cloud-init-vmware] in the
production environment, as well as locally for testing.

## Consequences

Cloud-init mostly runs the configuration once, when the instance is started. We
may need to move to a more fully featured solution (such as Ansible) for
configuration which needs to be updatable over time.


[cloud-init]: https://cloudinit.readthedocs.io/en/22.4.2/
[cloud-init-vmware]: https://cloudinit.readthedocs.io/en/22.4.2/topics/datasources/vmware.html
