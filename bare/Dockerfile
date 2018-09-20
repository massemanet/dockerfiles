FROM debian:9.5

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && apt-get install -y \
      apt-transport-https \
      apt-utils \
      aspell \
      bash-completion \
      build-essential \
      curl \
      emacs \
      git \
      gosu \
      make \
      man \
      python \
      software-properties-common \
      sudo \
      wget \
 && apt-get clean \
 && mkdir -p /opt/wrk

# the entrypoint will move these files after it has created a user.
COPY includes/ /opt/includes/

ENV PATH /usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /opt/wrk

ENTRYPOINT ["/opt/includes/entrypoint.sh"]
