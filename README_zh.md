# AndroidRemoteBuildWithDocker

当您在笔记本上编译一个大型的Android project时，可能觉得性能和电池都不够。而且，你还需要付出很多时间等待编译。
所以你一定很想要一个既高性能又便携的工作机器。那是不可能的。
我有过同样的困扰，不过我解决了。我过去常常建立一个远程编译的服务在我的台式机上。即可以用命令行控制远程编译服务，也可以使用Android Studio。
但是，有个问题是每次配置一个远程编译服务需要花很多时间。一堆步骤摆在我面前。这使我心累。所以，我做了这个repo，它同时集成了 两种技术：虚拟化技术 和 远程编译工具.


[Mainframer](https://github.com/buildfoundation/mainframer)正式我说的远程编译工具。它用于同步文件和执行编译指令. 它的官方说法: 
> A tool that executes a command on a remote machine while syncing files back and forth. The process is known as remote execution (in general) and remote build (in particular cases).
> It works via pushing files to the remote machine, executing the command there and pulling results to the local machine.

我需要重复： 它不但可以用命令行控制，还可以用Android studio。

在开头，我说配置远程编译的 Android环境需要**花很多时间**，但是现在我们有虚拟化技术, 比如 `Docker` and `Kubernetes`, 这项技术我经常使用，它使用简单且易于备份。

***在这个repo里, 我创建了一个docker镜像。它同时包含Android开发环境，和[Mainframer](https://github.com/buildfoundation/mainframer)***. 
如果你有高性能台式机/其他，它就是作为服务器。你可以运行这个repo在你的服务器。你的这台服务器，不要求一定与你的开发机器在 **同一局域网下**。***关于这点，我需要补充的是：在中国，你可能没有外网IP,就没办法在广域网下面连接到你的这台服务器，你可以尝试内网穿透技术。***


另外，你可以把这个docker image运行在云服务上。比如 google， amazon。 为了您的远程的且高性能的编译. Cloud services在性能和价格上面往往是弹性的。另外，你可能觉得cloud server高延迟.我需要阐明 : **延迟不会影响您的编译体验**因为 mainframer不会与您的笔记本沟通得那么的频繁。仅仅第一次编译，会传输大量的文件。除第一次之外的编译，不需要同步那么多的文件。

如上所述，我介绍了该repo的远程编译解决的一些问题。它可以解决笔记本性能不够，而台式机写代码又不够便携的问题,还有电池问题。
所以，当你建立好这个远程编译服务，你可以去咖啡馆，草地上，阳光下用笔记本写代码，且不需要充电。

接下来介绍如何使用。

## Server configuration
<details><summary>click to expand</summary>
第一步是编译docker镜像。在您的terminal中, run `docker build -t mainframer-docker .`

最后一步是启动镜像为一个容器: run `docker run --restart always -d -p 23:22 mainframer-docker`. 

现在，如果没有errors,  run `docker container ls | grep mainframer-docker` 去观察容器是否启动。我相信一切都很正常。

</details>

## Client configuration
<details><summary>click to expand</summary>

  客户端这边的步骤，我们需要做两件事，一个SSH key和一个ssh配置文件用于你的笔记本与服务器沟通。


  ```bash
  ssh-keygen -t rsa -f ~/.ssh/remote-builder -q -N ""
  #for mac, you may need to run: brew install ssh-copy-id
  # at the  following step, you might need to input password: root
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
  **别忘记替换上述 IP地址**

用ssh测试连接进服务器的docker: `ssh remote_builder`，命令输入之后没有报错的话，说明SSH connection是好的。

对于Android项目，你拷贝当前repo下的`.mainframer` 目录和一个文件`./mainframer.sh`到您的项目下。
然后，你可以运行` bash ./mainframer.sh ./gradlew assembleDebug`去尝试启动命令行编译.

**And now enjoy faster builds**

当然，你可以尝试直接使用AS UI的安装和调试，但是编译过程只跑在服务器上：
### 使用Android Studio远程编译

1. 用Android Studio打开 your project.

3. 点击 **Run → Edit Configuration → +**.

4. 选择你的项目的主application，它的名字一般为**App**.

5. 使用一个新的名字, e.g. remote-build.

6. 在 **Module**, 选择submodule name, 可能是 `app`。

7. 在 **Before Launch**, 点击 **-** 删除 `Gradle-aware Make`

8. 在 **Before Launch**, 点击 **+**, 添加 **Run External Tool**, 输入新的名字，比如： `remote assembleDebug`.

9. 在 **Program**, 输入 `bash`.

10. 在 **Parameters** 输入 `mainframer.sh ./gradlew :app:assembleDebug -Pandroid.enableBuildCache=true`

11. 最后一步, 在 **Working directory** , 输入 `$ProjectFileDir$`.


</details>

## 补充

**How to install other sdk?**

> 大多数情况下这是不需要关心的事情。sdk都是会自动下载的，androidsdk都已经很智能了。 
修改 Dockerfile 去重编docker镜像.或者使用如下步骤:

1. 启动 你的 docker.
2. 运行 `ssh remote_builder` 进入该 docker container. 这步可以用docker命令代替.
3. 此时你已经进入bash在你的docker容器中, run: 

    `/sdk/tools/bin/sdkmanager--install "ndk;21.0.6113669" --channel=3`.

**Mainframer also can build other kind of project**
You can fork this project to edit `Dockerfile` to make it work for your project.



**其他Mainframer的功能:**
[mainframer/v2.1.0 doc](https://github.com/buildfoundation/mainframer/tree/v2.1.0/samples/gradle-android)
简体
