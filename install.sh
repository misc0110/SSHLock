#!/bin/bash
if [ "$1" == "" ];
then
    echo "Usage: ./install.sh <admin user>"
    exit 1
fi

if [ -f /etc/ssh/sshrc ];
then
    echo -e "\033[0;31m/etc/ssh/sshrc exists, installation would overwrite this file, aborting...\033[0m" 1>&2
    exit 1
fi

sed s/MASTER_USER/"$1"/ <<'EOF' > /etc/ssh/sshrc
#!/bin/bash
if [ $(whoami) != "MASTER_USER" ];
then
        cur=$(whoami)
        if [ $(grep -ce "^$cur\$" /etc/ssh/lock) = 0 ];
        then
                lock=$(cat /etc/ssh/lock | tr -s '\n' ' ')
                echo "" 1>&2
                echo "" 1>&2
                echo "[sshlock] \033[0;31mMachine is locked by $lock! Exiting now...\033[0m" 1>&2
                echo "" 1>&2
                pkill -KILL -u $(whoami)
                kill -TERM $PPID
        fi
fi
# X11 forwarding
if read proto cookie && [ -n "$DISPLAY" ]; then
        if [ `echo $DISPLAY | cut -c1-10` = 'localhost:' ]; then
                # X11UseLocalhost=yes
                echo add unix:`echo $DISPLAY |
                    cut -c11-` $proto $cookie
        else
                # X11UseLocalhost=no
                echo add $DISPLAY $proto $cookie
        fi | xauth -q -
fi
EOF

if [ $? != 0 ];
then
    echo -e "\033[0;31mFailed to setup sshlock! Did you start as root?\033[0m" 1>&2
    exit 1
fi

touch /etc/ssh/lock
chmod a+w /etc/ssh/lock
cat <<'EOF' > /usr/local/bin/machine-lock
#!/bin/bash
lock=$(cat /etc/ssh/lock | tr -s '\n' ' ')
if [ "$lock" != "" ];
then
    echo -e "\033[0;33mMachine is already locked by $lock! Overwriting lock\033[0m"
fi
whoami > /etc/ssh/lock
echo "Machine is now locked"
EOF
chmod +x /usr/local/bin/machine-lock
cat <<'EOF' > /usr/local/bin/machine-unlock
#!/bin/bash
lock=$(cat /etc/ssh/lock | tr -s '\n' ' ')
current=$(whoami)
if [ "$lock" == "" ];
then
    echo -e "\033[0;33mMachine is not locked\033[0m"
    exit 0
fi
if [ "$lock" != "$current" ];
then
    echo -e "\033[0;33mMachine is locked by $lock! Removing lock\033[0m"
fi
echo "" > /etc/ssh/lock
echo "Machine is now unlocked"
EOF
chmod +x /usr/local/bin/machine-unlock
cat <<'EOF' > /usr/local/bin/machine-lock-add
#!/bin/bash
lock=$(cat /etc/ssh/lock)
current=$(whoami)
if [ "$lock" == "" ];
then
    echo -e "\033[0;33mMachine is not locked\033[0m"
    exit 0
fi
echo "$1" >> /etc/ssh/lock
echo "Machine is now available for '$1' as well."
EOF
chmod +x /usr/local/bin/machine-lock-add


echo "Done!"
echo "Use 'machine-lock' to lock the machine, and 'machine-unlock' to unlock it again."
echo "Use 'machine-lock-add <username>' to add another username that is allowed to log in."
