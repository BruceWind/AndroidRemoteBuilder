# it base on https://github.com/jangrewe/gitlab-ci-android.

##################################################################################################
# currently, it integrate sdk of android api 30.
#
#
#
#
#
##################################################################################################
FROM ubuntu:20.04


ENV VERSION_TOOLS "6609375"

ENV ANDROID_SDK_ROOT "/sdk"
ENV JAVA_SDK_ROOT="/usr/lib/jvm/java-8-openjdk-amd64/"
# Keep alias for compatibility
ENV ANDROID_HOME "${ANDROID_SDK_ROOT}"
ENV PATH "$PATH:${ANDROID_SDK_ROOT}/tools"
ENV DEBIAN_FRONTEND noninteractive


# Setup ssh server
RUN apt-get -qq update && \
  apt-get install -y openssh-server && \
  mkdir /var/run/sshd && \
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
  sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \ 
  sed -ri 's/#PermitUserEnvironment no/PermitUserEnvironment yes/g' /etc/ssh/sshd_config && \ 
  mkdir -p /root/.ssh/ && \
  touch /root/.ssh/environment && \
  echo "ANDROID_HOME=${ANDROID_SDK_ROOT}"  >> /root/.ssh/environment && \
  echo "JAVA_HOME=${JAVA_SDK_ROOT}"  >> /root/.ssh/environment && \
  touch /etc/enviroment && \
  echo "ANDROID_HOME=${ANDROID_SDK_ROOT}"  >> /etc/enviroment && \
  echo "JAVA_HOME=${JAVA_SDK_ROOT}"  >> /etc/enviroment
EXPOSE 22
CMD    ["/usr/sbin/sshd", "-D"]

RUN echo 'root:root' | chpasswd

RUN apt-get -qq update \
  && apt-get install -qqy --no-install-recommends \
  bzip2 \
  curl \
  nano \
  rsync \
  git-core \
  html2text \
  libc6-i386 \
  lib32stdc++6 \
  lib32gcc1 \
  lib32ncurses6 \
  lib32z1 \
  unzip \
  locales \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN apt-get update \
    && apt-get remove --purge openjdk-11-jdk-headless -y \
    && apt-get install -y openjdk-8-jdk

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN rm -f /etc/ssl/certs/java/cacerts; \
  /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN curl -s https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_TOOLS}_latest.zip > /tools.zip \
  && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
  && unzip /tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
  && rm -v /tools.zip

RUN mkdir -p $ANDROID_SDK_ROOT/licenses/ \
  && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_SDK_ROOT/licenses/android-sdk-license \
  && echo "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910" > $ANDROID_SDK_ROOT/licenses/android-sdk-preview-license \
  && yes | ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses >/dev/null  \
  && yes | ${ANDROID_HOME}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME}  "ndk-bundle"

ADD packages.txt /sdk
RUN mkdir -p /root/.android \
  && touch /root/.android/repositories.cfg \
  && ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --update

RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < /sdk/packages.txt \
  && ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} ${PACKAGES}

# Cleaning
RUN apt-get clean
