FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && apt-get install -y \
      apt-transport-https \
      apt-utils \
      aspell \
      awscli \
      bash-completion \
      build-essential \
      curl \
      emacs25-lucid \
      git \
      gosu \
      make \
      man \
      python \
      software-properties-common \
      sudo \
      tmux \
      wget \
 && apt-get clean \
 && chmod a+rwx /root \
 && chmod a+rwx /opt \
 && mkdir -p /opt/wrk

# the entrypoint will move these files after it has created a user.
COPY includes/ /opt/includes/

# use cask to compile emacs libs. then move it to /opt and change permissions.
# the entrypoint script will create a user and move them to the right place.
RUN curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python \
 && mv /opt/includes/Cask /root/.emacs.d/ \
 && cd /root/.emacs.d \
 && /root/.cask/bin/cask install \
 && mkdir fdlcap \
 && mv /opt/includes/fdlcap.el fdlcap \
 && mv /opt/includes/init.el . \
 && chmod -R a+rw .

RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
 && echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" \
      >/etc/apt/sources.list.d/kubernetes.list \
 && apt-get update \
 && apt-get install -y kubectl

RUN curl -s https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg \
 && install -o root -g root -m 644 /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/ \
 && echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" \
      > /etc/apt/sources.list.d/vscode.list \
 && apt-get update \
 && apt-get install -y \
      code \
      libxss1

ENV PATH /usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /opt/wrk

RUN useradd -m -s /bin/bash dockis \
 && echo "dockis ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER dockis

ENTRYPOINT ["/opt/includes/entrypoint.sh"]
