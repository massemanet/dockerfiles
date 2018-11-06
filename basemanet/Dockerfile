FROM bare:18.10

# the entrypoint will move these files after it has created a user.
COPY includes/ /opt/includes/

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

# install VS code
RUN curl -s https://packages.microsoft.com/keys/microsoft.asc | \
     gpg --dearmor > /tmp/microsoft.gpg \
 && sudo install -o root -g root -m 644 /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/ \
 && echo "deb https://packages.microsoft.com/repos/vscode stable main" \
        > /tmp/vscode.list \
 && sudo mv /tmp/vscode.list /etc/apt/sources.list.d/vscode.list \
 && sudo apt-get update \
 && sudo apt-get install -y \
      code \
      libxss1 \
 && sudo apt-get clean

ENTRYPOINT ["/opt/includes/entrypoint.sh"]
