#!/usr/bin/env sh
# only require this for members of the `users` group
id -nG "$USER" | grep -qw "users" || return
trap "exit 1" SIGINT SIGQUIT
if [ ! -f $HOME/.google_authenticator ]; then
    google-authenticator -ftDW -r 3 -R 30
fi
if [ ! -f $HOME/.google_authenticator ]; then
    exit 1
fi

if [ -z "$SSH_ORIGINAL_COMMAND" ]; then
    exec "$SHELL"
else
    exec "$SHELL" -c "$SSH_ORIGINAL_COMMAND"
fi
