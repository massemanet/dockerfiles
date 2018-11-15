FROM basemanet:18.10

ARG INTELLIJ_TARBALL

RUN sudo apt-get update \
 && sudo apt-get install -y \
      default-jdk-headless \
 && sudo apt-get clean

# install intellij
RUN mkdir /opt/intellij \
 && curl -v -L ${INTELLIJ_TARBALL} | \
      tar -C /opt/intellij -xz --strip-components=1 -f -

ENV PATH /opt/intellij/bin:$PATH
