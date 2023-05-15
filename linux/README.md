# Requirements

## Virtualbox 

So far, this only works on an Intel Mac. It would probably work on an Intel Linux machine as well.

``` shell
$ brew install virtualbox
```

You'll also need to put the Vault password (stored in 1Password) into
`.ansible_vault_password` or the `ANSIBLE_VAULT_PASSWORD` environment variable.

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
$ ssh -p5555 <username>@localhsot
```

# Ansible

To iterate on the Ansible configuration, you can run `ansible-pull` directly from an SSH connection:

``` shell
sudo ansible-pull -C main -U https://github.com/mbta/on_prem_deploy.git --vault-password-file /root/.ansible_vault_password -i linux/inventory.yml linux/main.yml
```
