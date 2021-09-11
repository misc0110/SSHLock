#!/bin/bash

sed s/MASTER_USER/"$1"/ <<'EOF' > /etc/ssh/sshrc
#!/bin/bash
if [ $$(whoami) != "MASTER_USER" ];
then
        lock=$(cat /etc/ssh/lock)
        if [ "$lock" != "" ];
        then
            if [ $(whoami) != $lock ];
            then
                    echo "" 1>&2
                    echo "" 1>&2
                    echo "\033[0;31mMachine is locked by $lock! Exiting now...\033[0m" 1>&2
                    echo "" 1>&2
                    pkill -KILL -u $(whoami)
                    kill -TERM $PPID
            fi
        fi
fi
EOF
touch /etc/ssh/lock
chmod a+w /etc/ssh/lock
cat <<EOF > /usr/local/bin/machine-lock
#!/bin/bash
whoami > /etc/ssh/lock
EOF
chmod +x /usr/local/bin/machine-lock
cat <<EOF > /usr/local/bin/machine-unlock
#!/bin/bash
echo "" > /etc/ssh/lock
EOF
chmod +x /usr/local/bin/machine-unlock

echo "Done!"
echo "Use 'machine-lock' to lock the machine, and 'machine-unlock' to unlock it again."
