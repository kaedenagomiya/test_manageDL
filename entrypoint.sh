#!/bin/bash -e

# check env val
if [ -z "$USER_NAME" ]; then
    echo "Error: USER_NAME is not set."
    exit 1
fi

USER_ID=$(id -u)
GROUP_ID=$(id -g)

# make group
echo "GROUP_ID: $GROUP_ID"
# when not root group
if [ x"$GROUP_ID" != x"0" ]; then
	if ! getent group $GROUP_ID > /dev/null; then
	groupadd -g ${GROUP_ID} ${USER_NAME}
fi

# make user
echo "USER_ID: $USER_ID"
# when not root user
if [ x"$USER_ID" != x"0" ]; then
	if ! id -u $USER_NAME > /dev/null 2>&1; then
	useradd -d /home/${USER_NAME} -m -s /bin/bash -u ${USER_ID} -g ${GROUP_ID} ${USER_NAME}
fi

# Restore permissions
sudo chmod u-s /usr/sbin/useradd
sudo chmod u-s /usr/sbin/groupadd

# Ensure that arguments containing spaces are also handled correctly.
exec "$@"
