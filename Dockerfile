FROM ubuntu:latest

# Specially for SSH access and port redirection
ENV ROOTPASSWORD android

# Expose ADB and ADB control ports
EXPOSE 5037
EXPOSE 5554
EXPOSE 5555

ENV DEBIAN_FRONTEND noninteractive
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections

# Add oracle-jdk to repositories
RUN add-apt-repository ppa:webupd8team/java

# Make sure the package repository is up to date
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list

# Update packages
RUN apt-get -y update

# Install oracle-jdk8
RUN apt-get -y install oracle-java8-installer

# Install android sdk
RUN wget https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
RUN tar -xvzf android-sdk_r24.4.1-linux.tgz
RUN mv android-sdk-linux /usr/local/android-sdk

# Add android tools and platform tools to PATH
ENV ANDROID_HOME /usr/local/android-sdk
ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Remove compressed files.
RUN cd /; rm android-sdk_r23-linux.tgz

# Some preparation before update
RUN chown -R root:root /usr/local/android-sdk/

# Install latest android tools and system images
RUN echo "y" | android update sdk --filter platform-tool --no-ui --force
RUN echo "y" | android update sdk --filter platform --no-ui --force
RUN echo "y" | android update sdk --filter build-tools-23.0.3 --no-ui -a
RUN echo "y" | android update sdk --filter sys-img-x86-android-24 --no-ui -a
RUN echo "y" | android update sdk --filter sys-img-armeabi-v7a-android-24 --no-ui -a

# Update ADB
RUN echo "y" | android update adb

# Create fake keymap file
RUN mkdir /usr/local/android-sdk/tools/keymaps
RUN touch /usr/local/android-sdk/tools/keymaps/en-us

# Add entrypoint 
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
