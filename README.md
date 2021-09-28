# AndroidRemoteBuildWithDocker

If you build Android project on MacBook or other laptops, you must think your computer performance is not enough. Your laptop battery is not enough as well.  And you must spend a lot time on waiting it.
So you may want a powerful and portable workstation. It is impossible. But you can build on remote desktop.
The trouble on me as well but I fixed it. I used to take a remote-build with [Mainframer](https://github.com/buildfoundation/mainframer) on my powerful desktop.
It is a problem that Mainframer configuring with Android will spend lost time. In case of building with a cloud service or new desktop, tremendous steps of configuration make me feel tired. Whereas a virtualization technology , such as `Docker` and `Kubernetes`, which I've used in everywhere is very efficient and easy in backup. 
In this repo, I make a docker image for a **builder server** that contains Android environment and [Mainframer](https://github.com/buildfoundation/mainframer). You can deploy a google cloud or amazon cloud server for your remote and powerful building. Furthermore, you can run on your desktop in case you have a powerful/high-performance PC with your laptop under one LAN. It works on not only **terminal** but also **Android Studio**.

## Server configuration
<details><summary>click to expand</summary>

First step is building docker image. In your terminal, run this command `docker build -t mainframer-docker .`

Last step is starting it: run `docker run --restart always -d -p 23:22 mainframer-docker`. 

Now, if there is no error,  run `docker container ls | grep mainframer-docker` to detect if it is started. May everything is very well.
</details>

## Client configuration
<details><summary>click to expand</summary>
Beside the project specific setup we need 2 more things, an ssh-key that is used to easily communicate between client and server. And a ssh configuring for our server.

  ```bash
  ssh-keygen -t rsa -f ~/.ssh/remote-builder -q -N ""
  #brew install ssh-copy-id
  ssh-copy-id -i ~/.ssh/remote-builder  -p 23 root@127.0.0.1

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

For android you can now just copy the mainframer folder and rename it `.mainframer` and you should run ` bash ./mainframer.sh ./gradlew assembleDebug`.

**And now enjoy faster builds**

### DEFAULT USER ROOT:ROOT IS USED IN THIS SETUP.



### build with Android Studio

1. open Android Studio， then do these steps：
  
2. use Android studio to open your project.

3. click **Run → Edit Configuration → +**.

4. select your **Android App**.

5. name a new name, e.g. remote-build.

6. in **Module**, select submodule name, may be `app`.

7. in **Before Launch**, click **-** to delete `Gradle-aware Make`

8. in **Before Launch**, click **+**, add **Run External Tool**, input a new name，like `remote assembleDebug`.


9.  in **Program**, input `bash`.

10. in **Parameters** input `mainframer.sh ./gradlew :app:assembleDebug -Pandroid.enableBuildCache=true`

11. in **Working directory** , input `$ProjectFileDir$`.


</details>

## In addition

**How to install other sdk?**
Modify Dockerfile to rebuild. Or follow these steps:

1. start your docker.
2. run `ssh remote_builder` to enter your docker container. Or use docker command to enter it.
3. by the time you entered the bash on your docker container, run `/sdk/tools/bin/sdkmanager--install "ndk;21.0.6113669" --channel=3`.

**Mainframer also can build other kind of project**
You can fork this project to edit `Dockerfile` to make it work for your project.



### Other features of Mainframer:
[mainframer/v2.1.0 doc](https://github.com/buildfoundation/mainframer/tree/v2.1.0/samples/gradle-android)