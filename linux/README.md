## Requirements

So far, this only works on an Intel Mac. It would probably work on an Intel Linux machine as well.

``` shell
$ brew install virtualbox
```

## Usage
``` shell
$ vagrant up
```

Vagrant may complain about `Authentication failure. Retrying...` and you can Control-C out of `vagrant up` at that point. 

You can SSH into the VM with either:

``` shell
$ vagrant ssh

# or 

$ ssh -p2222 <username>@localhost
```

To iterate on the Ansible configuration, you can run `ansible-pull` directly from an SSH connection:

``` shell
sudo ansible-pull -C linux -U https://github.com/paulswartz/on_prem_deploy.git linux/main.yml
```
