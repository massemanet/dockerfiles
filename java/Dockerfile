FROM debian:sid

ARG INTELLIJ_TARBALL

RUN apt-get update \
 && apt-get install -y \
      bash-completion \
      curl \
      git \
      gosu \
      sudo \
 && apt-get clean \
 && mkdir -p /opt/wrk

# the entrypoint will move these files after it has created a user.
COPY includes/ /opt/includes/

# install java9 plus netbeans
RUN mkdir /opt/intellij \
 && curl -v -L ${INTELLIJ_TARBALL} | \
      tar -C /opt/intellij -xz --strip-components=1 -f - \
 && apt-get install -y \
      java9-sdk-headless

ENV PATH /opt/intellij/bin:/usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /opt/wrk

ENTRYPOINT ["/opt/includes/entrypoint.sh"]

CMD /bin/bash
