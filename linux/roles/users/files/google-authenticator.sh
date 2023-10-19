#!/usr/bin/env sh

# trap exits, rather than allowing a user to ^C out of the script
trap "exit 1" INT QUIT

google_authenticator_path="${HOME:?}"/.google_authenticator

if [ ! -f "$google_authenticator_path" ]; then
    google-authenticator -ftDW -r 3 -R 30

    # Ensure that the Google Authenticator file was created
    test -f "$google_authenticator_path" || exit 1
fi

# Either run the shell, or the original command
if [ -z "$SSH_ORIGINAL_COMMAND" ]; then
    exec "$SHELL" -i
else
    exec "$SHELL" -c "$SSH_ORIGINAL_COMMAND"
fi
