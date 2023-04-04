## Requirements

So far, this only works on an Intel Mac. It would probably work on an Intel Linux machine as well.

``` shell
$ brew install virtualbox
```

## Usage
``` shell
$ vagrant up
```

Vagrant will complain about `Authentication failure. Retrying...` and you can Control-C out of `vagrant up` at that point. 

You can SSH into the VM with either:

``` shell
$ ssh -p2222 <username>@localhost
```

You'll also want to configure TOTP by running `google-authenticator` once you've
logged in with SSH in order to enable `sudo`.
