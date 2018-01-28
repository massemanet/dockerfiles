FROM ubuntu:17.10

RUN apt-get update \
 && apt-get upgrade -y \
      -o Dpkg::Options::="--force-confdef" \
      -o DPkg::Options::="--force-confold" \
 && apt-get install -y \
      curl emacs git gosu make python \
 && apt-get clean

RUN mkdir -p /opt/emacs/tmp \
 && curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python

ADD bashrc    /root/.bashrc
ADD init.el   /root/.emacs.d/init.el
ADD Cask      /root/.emacs.d/Cask
ADD fdlcap.el /root/.emacs/d/fdlcap/fdlcap.el

RUN cd /root/.emacs.d \
 && /root/.cask/bin/cask install

ENV PATH /usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /opt/emacs/tmp

COPY ../entrypoint.sh /root/entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]
