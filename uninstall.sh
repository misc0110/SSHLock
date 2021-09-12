#!/bin/bash

rm /etc/ssh/sshrc
rm /etc/ssh/lock
rm /usr/local/bin/machine-lock
rm /usr/local/bin/machine-unlock

echo "Done!"
echo "Use 'machine-lock' to lock the machine, and 'machine-unlock' to unlock it again."
