# Requirements

## Mise

[Mise](https://mise.jdx.dev/) is an alternative to ASDF.

``` shell
$ mise install
```

## ASDF

Not needed if using Mise (above).

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
$ brew install vagrant --cask
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
# optional: set a different remote branch to test (default: main)
# this branch must exist and be current on the remote in order to test it
export GIT_BRANCH="my_branch_to_test"
# start the VM with the specified hostname
bash run_qemu.sh <hostname>
```

And you can SSH into the VM with

``` shell
$ ssh -p5555 <username>@localhost
```

You can also configure the hostname in `~/.ssh/config`:

``` ssh-config
Host <hostname>
    Hostname localhost
    User <username>
    Port 5555
```

# Ansible

To iterate on the Ansible configuration, you can run `ansible-pull` directly from an SSH connection:

``` shell
ansible-pull -C main -U https://github.com/mbta/on_prem_deploy.git --vault-password-file /root/.ansible_vault_password -i linux/inventory.yml linux/main.yml
```

If you have the relevant hostname configured in `~/.ssh/config` (so that `ssh <hostname>` works), you can also run the playbook from your local machine:

``` shell
ansible-playbook main.yml -i inventory.yml --vault-password-file .ansible_vault_password -c ssh --become -l <hostname>
```

Ansible Vault is used for storing some kinds of low-secrecy values, where they
should not be public but are not otherwise secret inside the MBTA.

While they are encrypted, long-term credentials (such as AWS access keys or
passwords) should not be stored with `ansible-vault encrypt`. Instead, fetch
those credentials from a more secure source, such as S3 using SSM credentials.

# OVA installer

To create an OVA for running in MBTA's VMware environment, you'll need:

- the hostname
- the IP address

You'll also want to generate a random temporary password (i.e. with 1Password) to use in case there's an issue with running Ansible.

```shell
$ INITIAL_PASSWORD=<initial password> bash build_ova.sh <hostname> <IP address>
```

This will create `tmp/<hostname>.ova`. Upload this file to SharePoint, and share it with ITD for them to install.

If everything goes well, Ansible will run on the VM, create normal user accounts, and connect up to AWS and Splunk.

If that doesn't happen, you can try:

- logging into the server directly with your username/SSH key
- logging into the server directly with `ubuntu` and the random initial password

If neither of those work, you'll need to work with ITD to ensure the VM is running and perform any additional debugging.

# SCU installer

To create an SCU installation USB drive:

Install the `xorriso` package using your system's package manager.

Download an [Ubuntu Server 22.04](https://ubuntu.com/download/server) image.

Create the installer image with the following command. To create an installer for the test environments, add the `--staging` option
``` shell
./build_scu_iso --input PATH_TO_UBUNTU_IMAGE
```

Write `tmp/output.iso` to the USB drive with your tool of choice.
