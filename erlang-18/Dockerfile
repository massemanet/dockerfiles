FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && apt-get install -y \
      apt-transport-https \
      apt-utils \
      bash-completion \
      build-essential \
      curl \
      emacs24-lucid \
      git \
      gosu \
      make \
      man \
      python \
      software-properties-common \
      sudo \
      tmux \
 && apt-get clean \
 && mkdir -p /opt/wrk

# install erlang from erlang solutions
# we only install a subset of the packages
# we get a stock rebar3 as well
RUN curl http://packages.erlang-solutions.com/erlang/esl-erlang/FLAVOUR_1_general/esl-erlang_18.3.4.5-1~ubuntu~zesty_amd64.deb > \
     /tmp/esl-erlang_18.3.4.5-1~ubuntu~zesty_amd64.deb \
 && dpkg -i  /tmp/esl-erlang_18.3.4.5-1~ubuntu~zesty_amd64.deb \
 || true

RUN apt-get install -fy \
 && curl https://s3.amazonaws.com/rebar3/rebar3 > /usr/bin/rebar3 \
 && chmod +x /usr/bin/rebar3
