FROM bare:18.10

RUN useradd -m -s /bin/bash dockis \
 && echo "dockis ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER dockis

# install awscli and kubectl
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
        sudo apt-key add - \
 && echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" \
        > /tmp/kubernetes.list \
 && sudo mv /tmp/kubernetes.list /etc/apt/sources.list.d/kubernetes.list \
 && sudo apt-get update \
 && sudo apt-get install -y \
      awscli \
      kubectl \
 && sudo apt-get clean

# install aws-vault
RUN curl -sSL https://github.com$(curl -sSL https://github.com/99designs/aws-vault/releases | \
        grep -oE "/99designs/.*/aws-vault-linux-amd64" | \
        sort -V | tail -n1) > /tmp/aws-vault \
 && sudo install /tmp/aws-vault /usr/bin

# install keybase
RUN curl -sSL https://prerelease.keybase.io/keybase_amd64.deb > /tmp/keybase.deb \
 && sudo dpkg -i /tmp/keybase.deb || true \
 && sudo apt-get install -yf

# the entrypoint will move these files after it has created a user.
COPY includes/ /opt/includes/

# use cask to compile emacs libs. then move it to /opt and change permissions.
# the entrypoint script will create a user and move them to the right place.
RUN curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python \
 && cp /opt/includes/Cask $HOME/.emacs.d/ \
 && cd $HOME/.emacs.d \
 && $HOME/.cask/bin/cask install \
 && mkdir fdlcap \
 && cp /opt/includes/fdlcap.el fdlcap \
 && cp /opt/includes/init.el . \
 && chmod -R a+rw .

ENV ESHELL /bin/bash

ENTRYPOINT ["/opt/includes/entrypoint.sh"]
