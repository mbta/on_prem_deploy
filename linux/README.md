# Requirements

## RTX

[RTX](https://github.com/jdxcode/rtx) is an alternative to ASDF.

``` shell
$ rtx install
```

## ASDF

Not needed if using RTX (above).

``` shell
$ ASDF_PYAPP_INCLUDE_DEPS=1 asdf plugin add ansible https://github.com/amrox/asdf-pyapp.git
$ asdf plugin-add adr-tools
$ asdf plugin-add shellcheck
$ asdf install
```

You'll also need to put the Vault password (stored in 1Password) into
`.ansible_vault_password` or the `ANSIBLE_VAULT_PASSWORD` environment variable.

## Virtualbox 

So far, this only works on an Intel Mac. It would probably work on an Intel Linux machine as well.

``` shell
$ brew install virtualbox
$ brew install hashicorp/tap/hashicorp-vagrant
```

### Usage
``` shell
$ vagrant plugin install vagrant-env
$ vagrant plugin install vagrant-vbguest
$ vagrant up
```

Vagrant may complain about `Authentication failure. Retrying...` and you can Control-C out of `vagrant up` at that point. 

You can SSH into the VM with either:

``` shell
$ vagrant ssh

# or 

$ ssh -p2222 <username>@localhost
```

## QEMU

QEMU will work on an M1.

``` shell
$ brew install qemu
```

### Usage

``` shell
bash run_qemu.sh
```

And you can SSH into the VM with

``` shell
$ ssh -p5555 <username>@localhost
```

You can also configure the hostname in `~/.ssh/config`:

``` ssh-config
Hostname qemu
  Username <username>
  Port 5555
```

# Ansible

To iterate on the Ansible configuration, you can run `ansible-pull` directly from an SSH connection:

``` shell
ansible-pull -C main -U https://github.com/mbta/on_prem_deploy.git --vault-password-file /root/.ansible_vault_password -i linux/inventory.yml --become linux/main.yml
```

If you have the relevant hostname configured in `~/.ssh/config` (so that `ssh <host>` works), you can also run the playbook from your local machine:

``` shell
ansible-playbook main.yml -i inventory.yml --vault-password-file .ansible_vault_password -c ssh --become -l <hostname>
```

Ansible Vault is used for storing some kinds of low-secrecy values, where they
should not be public but are not otherwise secret inside the MBTA.

While they are encrypted, long-term credentials (such as AWS access keys or
passwords) should not be stored with `ansible-vault encrypt`. Instead, fetch
those credentials from a more secure source, such as S3 using SSM credentials.
