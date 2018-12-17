ARG FROM_IMAGE
FROM ${FROM_IMAGE}

RUN sudo apt-get update \
 && sudo apt-get install -y \
        default-jdk-headless \
        g++ \
        pgadmin3 \
        pkg-config \
        unzip \
        wireshark-gtk \
        zip \
        zlib1g-dev \
 && sudo apt-get clean

# install intellij
ARG INTELLIJ_TARBALL

RUN mkdir /opt/intellij \
 && curl -v -L ${INTELLIJ_TARBALL} | \
      tar -C /opt/intellij -xz --strip-components=1 -f -

ENV PATH /opt/intellij/bin:$PATH

# install erlang + rebar + redbug
RUN curl https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb > \
     /tmp/erlang-solutions_1.0_all.deb \
 && sudo dpkg -i /tmp/erlang-solutions_1.0_all.deb \
 && sudo apt-get update \
 && sudo apt-get install -y \
     erlang-common-test erlang-eunit erlang-dialyzer \
     erlang-mode erlang-parsetools erlang-dev \
 && curl https://s3.amazonaws.com/rebar3/rebar3 > /tmp/rebar3 \
 && sudo mv /tmp/rebar3 /usr/bin/rebar3 \
 && sudo chmod +x /usr/bin/rebar3 \
 && cd ~ \
 && git clone https://github.com/massemanet/redbug \
 && cd redbug \
 && git checkout v2.0 \
 && make

# install go from tarball
ARG GO_TARBALL

RUN mkdir -p /opt/go \
 && curl -v -L ${GO_TARBALL} | \
      tar -C /opt/go -x -z --strip-components=1 -f -

ENV GOROOT /opt/go
ENV PATH $GOROOT/bin:$PATH

# install bazel
ARG BAZEL_SCRIPT

RUN curl -sSL ${BAZEL_SCRIPT} > /tmp/bazel.sh \
 && chmod +x /tmp/bazel.sh \
 && sudo bash -x /tmp/bazel.sh \
 && /usr/local/bin/bazel help \
 && sudo ln -s /usr/local/lib/bazel/bin/bazel-complete.bash /etc/bash_completion.d

ENV PATH /usr/local/bin:$PATH

# finish
COPY includes /opt/includes

