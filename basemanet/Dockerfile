FROM ubuntu:17.10

RUN apt-get update \
 && apt-get install -y \
      aspell \
      awscli \
      bash-completion \
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
RUN curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python \
 && mv /opt/includes/Cask /root/.emacs.d/ \
 && cd /root/.emacs.d \
 && /root/.cask/bin/cask install \
 && mkdir fdlcap \
 && mv /opt/includes/fdlcap.el fdlcap \
 && mv /opt/includes/init.el . \
 && chmod -R +rw .

ENV PATH /usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /opt/wrk

ENTRYPOINT ["/opt/includes/entrypoint.sh"]

CMD /bin/bash
