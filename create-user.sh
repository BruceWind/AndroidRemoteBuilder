#!/bin/bash
################################################################################################################
# this file is copied from https://github.com/buildfoundation/mainframer. 
# More detail you can open the page to look at.
#######################################################################################################################
# This shell is supposed to run on your remote server to create users.
# --------------------------------------------------------------------------
# As clients push local project file to server, then project file will save at "/home/{User}/mainframer/{project_name}/"
# on remote server.
# Due to the fact that where file saved at is accords to user name, when you want multi-clients to connect 
# one docker within remote server, you must need this shell to create several users on remote server.
# -------------------how to run-------------------------------------------------------------------------------
# bash create-user.sh "USER_NAME" "USER_SSH_PUBLIC_KEY"
########################################################################################################################

set -eux

USER_NAME="$1"
USER_SSH_PUBLIC_KEY="$2"

if [ -z "${USER_NAME}" ]; then
  echo "Error: user name is not provided."
  exit 1
fi

if [ -z "${USER_SSH_PUBLIC_KEY}" ]; then
  echo "Error: user SSH public key is not provided."
  exit 1
fi

echo ":: Creating user [${USER_NAME}]..."

# Create user.
useradd "${USER_NAME}" --create-home

# Change shell to Bash.
chsh -s /bin/bash "${USER_NAME}"

# Switch to user directory.
pushd "/home/${USER_NAME}"

# Configure SSH access.
SSH_DIR=".ssh"
SSH_KEYS_FILE="${SSH_DIR}"/authorized_keys

mkdir -p "${SSH_DIR}"
touch "${SSH_KEYS_FILE}"

chmod u+rw "${SSH_DIR}"
chmod u+rw "${SSH_KEYS_FILE}"
echo "${USER_SSH_PUBLIC_KEY}" > "${SSH_KEYS_FILE}"


# Change ownership to all affected files.
chown -R "${USER_NAME}":"${USER_NAME}" "/home/${USER_NAME}/"

echo ":: Created user [${USER_NAME}]!"

# Switch from user directory.
popd
