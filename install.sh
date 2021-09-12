#!/bin/bash
if [ "$1" == "" ];
then
    echo "Usage: ./install.sh <admin user>"
    exit 1
fi

sed s/MASTER_USER/"$1"/ <<'EOF' > /etc/ssh/sshrc
#!/bin/bash
if [ $(whoami) != "MASTER_USER" ];
then
        lock=$(cat /etc/ssh/lock)
        if [ "$lock" != "" ];
        then
            if [ $(whoami) != $lock ];
            then
                    echo "" 1>&2
                    echo "" 1>&2
                    echo "[sshlock] \033[0;31mMachine is locked by $lock! Exiting now...\033[0m" 1>&2
                    echo "" 1>&2
                    pkill -KILL -u $(whoami)
                    kill -TERM $PPID
            fi
        fi
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
lock=$(cat /etc/ssh/lock)
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
lock=$(cat /etc/ssh/lock)
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

echo "Done!"
echo "Use 'machine-lock' to lock the machine, and 'machine-unlock' to unlock it again."
