FROM debian:9

ARG SDK_VSN

RUN apt-get update \
 && apt-get install -y \
      apt-transport-https \
      bash-completion \
      curl \
      emacs \
      gettext \
      git \
      gnupg \
      gosu \
      libunwind8 \
      make \
      python \
      sudo \
 && apt-get clean \
 && mkdir -p /opt/wrk

# the entrypoint will move these files after it has created a user.
COPY includes/ /opt/includes/

# use cask to compile emacs libs. then move it to /opt and change permissions.
# the entrypoint script will create a user and move them to the right place.
RUN curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python \
 && mv /opt/includes/Cask /root/.emacs.d/ \
 && cd /root/.emacs.d && /root/.cask/bin/cask install \
 && cd /root && mv .emacs.d /opt/includes && chmod -R +r /opt/includes/.emacs.d

RUN curl https://packages.microsoft.com/keys/microsoft.asc | \
      gpg --dearmor > microsoft.gpg \
 && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg \
 && sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/dotnetdev.list' \
 && apt-get update \
 && apt-get install -y \
      dotnet-sdk-${SDK_VSN}

ENV PATH /usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /opt/wrk

ENTRYPOINT ["/opt/includes/entrypoint.sh"]

CMD /bin/bash
