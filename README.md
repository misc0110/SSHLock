# SSHLock

This framework sets up a remote machine to allow users to lock and unlock it for other remote users. 
When a user locks the machine, SSH connections by other users are immediately aborted with a message containing the username of the user currently locking the machine. 
One administrator account can be defined that can always log in and also remove any lock. 

## Technical Details
SSHLock uses the file `/etc/ssh/sshrc` file to implement the locking logic.
The user currently holding the lock is stored in the world-writable file `/etc/ssh/lock`. 
The `machine-lock` and `machine-unlock` scripts simply modify this file. 
An administrator user given during installation is always exempt from the locking logic. 

## Installation
