FROM basemanet:18.04

ARG INTELLIJ_TARBALL

RUN apt-get update \
 && apt-get install -y \
      default-jdk-headless \
 && apt-get clean \
 && mkdir -p /opt/wrk

# install intellij
RUN mkdir /opt/intellij \
 && curl -v -L ${INTELLIJ_TARBALL} | \
      tar -C /opt/intellij -xz --strip-components=1 -f -

ENV PATH /opt/intellij/bin:$PATH
