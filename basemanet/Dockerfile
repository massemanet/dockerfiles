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
      emacs \
      git \
      gosu \
      make \
      man \
      python \
      sudo \
      tmux \
 && apt-get clean \
 && mkdir -p /opt/wrk

# the entrypoint will move these files after it has created a user.
COPY includes/ /opt/includes/

# use cask to compile emacs libs. then move it to /opt and change permissions.
# the entrypoint script will create a user and move them to the right place.
RUN chmod a+rwx /root \
 && curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python \
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

ENV PATH /usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /opt/wrk

ENTRYPOINT ["/opt/includes/entrypoint.sh"]

CMD /bin/bash
