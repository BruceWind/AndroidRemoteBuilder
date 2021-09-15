# AndroidRemoteBuildImage


Mainframer setup in docker to easily deploy it on all powerful servers

# Build server
In order to build the docker image run following command `docker build -t mainframer-docker .`
  * The docker image is setup to build go, clang, gcc, buck, rust, gradle and gradle android projects. If you want to make your docker image smaller you can comment out what you don't need in the Dockerfile.

  To run the docker image run `docker run -d -p 23:22 mainframer-docker`.

# Client

Beside the project specific setup we need 2 more things, an ssh-key in order to make communication between client and server easier to maintain. And a ssh config for our server.

  ```bash
  ssh-keygen -t rsa -f ~/.ssh/remote-builder -q -N ""
  #brew install ssh-copy-id
  ssh-copy-id -i ~/.ssh/remote-builder root@127.0.0.1 -p 23

  echo -e "Host remote_builder
            User root 
            HostName 127.0.0.1 
            Port 23 
            IdentityFile ~/.ssh/remote-builder 
            PreferredAuthentications publickey 
            ControlMaster auto 
            ControlPath /tmp/%r@%h:%p 
            ControlPersist 1h" >> ~/.ssh/config
  ```
  **REPLACE IP ADDRESS**

To SSH to the docker container: `ssh remote_builder`

For android you can now just copy the mainframer folder and rename it `.mainframer` and you should be go to run ` bash ./mainframer.sh ./gradlew assembleDebug`.

**And now enjoy faster builds**

### DEFAULT USER ROOT:ROOT IS USED IN THIS SETUP.


### In addition
when you got the error:
```
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/xxx/.ssh/remote-builder.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed

/usr/bin/ssh-copy-id: ERROR: @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
ERROR: @    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
ERROR: @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
ERROR: IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
ERROR: Someone could be eavesdropping on you right now (man-in-the-middle attack)!
ERROR: It is also possible that a host key has just been changed.
ERROR: The fingerprint for the ECDSA key sent by the remote host is
ERROR: SHA256:tbW7XTrFLjqAIUp+SjQ+koR+GJak26E+rmXfLs5w7Es.
ERROR: Please contact your system administrator.
ERROR: Add correct host key in /home/xxx/.ssh/known_hosts to get rid of this message.
ERROR: Offending ECDSA key in /home/xxx/.ssh/known_hosts:32

ERROR:   remove with:
ERROR:   ssh-keygen -f "/home/xxx/.ssh/known_hosts" -R "[127.0.0.1]:23"
ERROR: ECDSA host key for [127.0.0.1]:23 has changed and you have requested strict checking.
ERROR: Host key verification failed.
```
Obviously, you need run `ERROR:   ssh-keygen -f "/home/xxx/.ssh/known_hosts" -R "[127.0.0.1]:23"`. and retry.

A next error:
```

FAILURE: Build failed with an exception.

* What went wrong:
Could not determine java version from '11.0.11'.

```
run `./gradlew wrapper --gradle-version 5.1.1`