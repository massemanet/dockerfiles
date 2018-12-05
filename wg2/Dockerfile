ARG FROM_IMAGE
FROM ${FROM_IMAGE}

ARG INTELLIJ_TARBALL

RUN sudo apt-get update \
 && sudo apt-get install -y \
      default-jdk-headless \
      pgadmin3 \
      wireshark-gtk \
 && sudo apt-get clean

# install intellij
RUN mkdir /opt/intellij \
 && curl -v -L ${INTELLIJ_TARBALL} | \
      tar -C /opt/intellij -xz --strip-components=1 -f -

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
 && sudo chmod +x /usr/bin/rebar3

RUN cd ~ \
 && git clone https://github.com/massemanet/redbug \
 && cd redbug \
 && git checkout v2.0 \
 && make

COPY includes /opt/includes

ENV PATH /opt/intellij/bin:$PATH
