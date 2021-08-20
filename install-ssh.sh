#!/bin/bash
set -e
#check if ssh service is available
if [ $(service --status-all | grep -q "ssh" && echo $?) ]
then
        echo "ssh is available"
        sudo systemctl start ssh
        sudo systemctl enable ssh
else
        echo "ssh is not available"
        apt-get install -y openssh-server
        sudo systemctl start ssh
        sudo systemctl enable ssh
fi
#generate key
#variable:
USER=coangha
FILENAME=~/.ssh/sshkey
KEYTYPE=rsa
SSH_KEYGEN=`which ssh-keygen`

if [ -d ~/.ssh ]
then
        echo ".ssh is available"
else
        mkdir ~/.ssh
        chmod 700 ~/.ssh
        chown ${USER}.${USER} ~/.ssh
fi

if [ -f ~/.ssh/authorized_keys ]
then
        echo "authorized_keys is availabe"
else
        touch ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
        chown ${USER}.${USER} ~/.ssh/authorized_keys
fi

#check if ssh-key is already generated
if [ -f $FILENAME ]
then
        #key is available
        #if private key is not in authorize keys, copy it
        pubkey=`cat ${FILENAME}.pub`
        authkey=`grep -o $pubkey ~/.ssh/authorize_keys` || true
        if [[ "$pubkey" != "$authkey" ]]
        then
                cat ${FILENAME}.pub >> ~/.ssh/authorized_keys
        fi
else
        #generated key and add public key to authorized key
        sudo runuser -u $USER -- $SSH_KEYGEN -t $KEYTYPE -f $FILENAME -N ''
        cat ${FILENAME}.pub >> ~/.ssh/authorized_keys
        cat $FILENAME
fi
