# AndroidRemoteBuildWithDocker

If you build large Android project on MacBook or other laptops, you must think your computer performance is not enough. Your laptop battery is not enough as well.  And you must spend a lot time on waiting it.
So you may want a powerful and portable workstation. It is impossible but you can build on remote desktop.
The trouble on me as well but I fixed it. I used to establish a remote-builder on my powerful desktop. I control the remote-builder by not only terminal but also Android studio.
A problem is that remote-builder configuring with Android will spend lots time. In building it on a cloud service or new desktop, tremendous steps of configuration make me tired. So I made this repo integrate with a couple of technologies: Docker and  [Mainframer](https://github.com/buildfoundation/mainframer).

The Mainframer works for remote building. Its official explain: 
> A tool that executes a command on a remote machine while syncing files back and forth. The process is known as remote execution (in general) and remote build (in particular cases).
> It works via pushing files to the remote machine, executing the command there and pulling results to the local machine.

And I have to tell you that it work not only temrinal but also Android studio.

Before I said that remote-builder configuring with Android will spend lots time but we have virtualization technology, such as `Docker` and `Kubernetes`, which I've used in everywhere is high-performance and easy to use and backup. 
***In this repo, I make a docker image that contains Android environment and [Mainframer](https://github.com/buildfoundation/mainframer)***. 
You can run it on your desktop in case you have a powerful/high-performance desktop. It is not required that the desktop and your laptop **under one LAN**. In case the desktop you can connect from anywhere, it can be set the docker image. Furthermore, you can put the docker image on a cloud service, such as, google or amazon cloud server, for your remote and powerful building. Cloud services are elastic in performance and price. Besides, you may think cloud server is high-latency. I have to explain that latency won't effect your building experience because mainframer does not to communitcate your laptop many times in a building process. Even copying files only in before and after buiding build. And the full-file-copy task only once.

To sum up, I explained that the repo works for remote-building. It is able to solve laptop performance and save more power from battery. So after you establish a remote-builder, you can bring you laptop to coffee shop, grass and sunshine without electric charging. 

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

1. open Android Studio to open your project.

3. click **Run → Edit Configuration → +**.

4. select your **Android App**.

5. name a new name, e.g. remote-build.

6. in **Module**, select submodule name, may be `app`.

7. in **Before Launch**, click **-** to delete `Gradle-aware Make`

8. in **Before Launch**, click **+**, add **Run External Tool**, input a new name，like `remote assembleDebug`.

9.  in **Program**, input `bash`.

10. in **Parameters** input `mainframer.sh ./gradlew :app:assembleDebug -Pandroid.enableBuildCache=true`

11. The last step, in **Working directory** , input `$ProjectFileDir$`.


</details>

## In addition

**How to install other sdk?**

Modify Dockerfile to rebuild. Or follow these steps:

1. start your docker.
2. run `ssh remote_builder` to enter your docker container. Or use docker command to enter it.
3. by the time you entered the bash on your docker container, run: 

    `/sdk/tools/bin/sdkmanager--install "ndk;21.0.6113669" --channel=3`.

**Mainframer also can build other kind of project**
You can fork this project to edit `Dockerfile` to make it work for your project.



**More features of Mainframer:**
[mainframer/v2.1.0 doc](https://github.com/buildfoundation/mainframer/tree/v2.1.0/samples/gradle-android)
