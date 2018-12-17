ARG FROM_IMAGE
FROM ${FROM_IMAGE}

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN yes | /usr/local/sbin/unminimize \
 && apt-get update \
 && apt-get install -y \
      apt-transport-https \
      apt-utils \
      aspell \
      bash-completion \
      build-essential \
      curl \
      emacs-lucid \
      git \
      gosu \
      jq \
      lsof \
      make \
      man \
      pass \
      python-uinput \
      software-properties-common \
      strace \
      sudo \
      tmux \
      wget \
      xpra \
 && apt-get clean \
 && chmod a+rwx /root \
 && chmod a+rwx /opt \
 && mkdir -p /opt/wrk

ENV PATH /usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /opt/wrk
