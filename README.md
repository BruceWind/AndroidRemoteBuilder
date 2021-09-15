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

To SSH to the docker container: `ssh REMOTE_BUILDER`

For android you can now just copy the mainframer folder and rename it `.mainframer` and you should be go to run ` bash ./mainframer.sh ./gradlew assembleDebug`.

**And now enjoy faster builds**

### DEFAULT USER ROOT:ROOT IS USED IN THIS SETUP.