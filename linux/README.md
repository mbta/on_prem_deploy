## Requirements

So far, this only works on an Intel Mac. It would probably work on a

``` shell
$ brew install qemu
```

## Usage
In one tab:
``` shell
$ python3 -m http.server --directory ./cloud-init
```

In another tab:

``` shell
$ ./run-local.sh
```

Once that finishes (you'll see the SSH fingerprints for the user SSH keys), in a third tab:

``` shell
$ ssh -p 5555 <username>@localhost
```

You'll also want to configure TOTP by running `google-authenticator` once you've
logged in with SSH.
