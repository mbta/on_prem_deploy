# Overview

This directory contains [Ansible](https://docs.ansible.com/) configuration for
provisioning Linux servers, as well as scripts for building OVA images that can
be deployed into virtualization environments.

## How We Use This Repo

- We build an OVA using the [`build_ova.sh`](build_ova.sh) script (see
  [OVA installer](#ova-installer))
- On first boot of the server, `cloud-init` runs Ansible in pull mode (see
  [`cloud-init/user-data`](cloud-init/user-data))
- `ansible-pull` runs hourly via systemd, which pulls this repo and runs the
  relevant plays according to the roles defined in [`main.yml`](main.yml) and
  the corresponding hostname in [`inventory.yml`](inventory.yml)
- All ongoing maintenance, including updates and configuration changes, happens
  via the Ansible configuration in this repo

## Setup

``` shell
$ asdf plugin add adr-tools
$ asdf plugin add shellcheck
$ asdf plugin add uv
$ asdf install
```

Use `uv run` to run Python tools such as `ansible`. For example:

``` shell
$ uv run ansible --version
```

## Ansible Vault

Ansible Vault is used to obfuscate some sensitive but non-secret configuration which should not be public.
Note that **secrets and other credentials should not be stored in this repo**.

To ensure that the Vault
can be decrypted by servers, or to decrypt it locally, you'll need to put the
Vault password (stored in 1Password) into `.ansible_vault_password` or the
`ANSIBLE_VAULT_PASSWORD` environment variable.

After writing `.ansible_vault_password`, you can encrypt and decrypt vaults locally with
`uv run ansible-vault decrypt path/to/vault.yml`

While they are encrypted, long-term credentials (such as AWS access keys or
passwords) should not be stored with `ansible-vault encrypt`. Instead, fetch
those credentials from a more secure source, such as S3 using SSM credentials.

## Deploying

The deploy process is:
1. Merge changes into `origin/main`
2. All on prem machines poll GitHub hourly to check for updates to `main`.
3. If there are any updates, each machine pulls them and applies the update.

There's no way to push code to one server but not another. They all pull from the same git branch.

Each server decide which plays to run based on the listing for its hostname in the inventory.

## Ansible Testing

As of this writing, all testing of provisioning scripts and Ansible
configuration must be performed manually.

1. Make a new branch `origin/my-branch` that matches main: `git push origin main:my-branch`
2. Run a VM locally using either Vagrant or Qemu, and point it at GitHub `origin/my-branch`.
    - The hostname should match the hostname of the server in inventory that you want to pretend to be.
3. Let the server initialize.
    - It's ready when the server says `Cloud-init v. <version> finished at <...>`
    - Now your local VM should be in the same state as the real on prem server.
4. Push your changes to `origin/my-branch`: `git push origin my-branch:my-branch`
5. Tell the server to pull the new ansible config (see below).
6. See if it worked. If it did, then the real servers should, too, once the change is merged to main and they pull it.

### Virtualbox / Vagrant

So far, this only works on an Intel Mac. It would probably work on an Intel Linux machine as well.

``` shell
$ brew install virtualbox
$ brew install vagrant --cask
```

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

### QEMU

QEMU will work on an M1.

``` shell
$ brew install qemu
```

``` shell
# optional: set a different remote branch to test (default: main)
# this branch must exist and be current on the remote in order to test it
export GIT_BRANCH="my_branch_to_test"
bash run_qemu.sh <hostname>
# or, in one line:
env GIT_BRANCH="my_branch_to_test" run_qemu.sh <hostname>
```

And you can SSH into the VM with

``` shell
$ ssh -p5555 <username>@localhost
```

You can also configure the hostname in `~/.ssh/config`:

``` ssh-config
Host <hostname>
    Hostname localhost
    User <username, use `ubuntu` if testing startup>
    Port 5555
```

To quit QEMU, type `Ctrl-a`, then `x`.

### SSH

The username you SSH as should match one of the users in `users.yml`, and it uses the SSH pulic key you have on github.

On your first ssh login, you'll be prompted set up a TOTP key (just like in prod).

### Telling a server to pull the new Ansible config

Option 1: Wait 1 hour. The server polls for updates from github regularly.

Option 2: SSH in, then run `sudo systemctl start ansible-pull`

Option 3:

If you have the relevant hostname configured in `~/.ssh/config` (so that `ssh <hostname>` works), you can also run the playbook from your local machine:

``` shell
uv run ansible-playbook main.yml -i inventory.yml --vault-password-file .ansible_vault_password -c ssh --become -l <hostname>
```

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
