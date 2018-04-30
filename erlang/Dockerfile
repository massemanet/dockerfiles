FROM ubuntu:17.10

RUN apt-get update \
 && apt-get install -y \
      aspell \
      awscli \
      bash-completion \
      curl \
      emacs \
      git \
      gosu \
      make \
      man \
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

# install erlang from erlang solutions
# we only install a subset of the packages
# we get a stock rebar3 as well
RUN curl https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb > \
     /tmp/erlang-solutions_1.0_all.deb \
 && dpkg -i /tmp/erlang-solutions_1.0_all.deb \
 && apt-get install -y \
     erlang-common-test erlang-eunit erlang-dialyzer \
     erlang-mode erlang-parsetools erlang-dev \
 && curl https://s3.amazonaws.com/rebar3/rebar3 > /usr/bin/rebar3 \
 && chmod +x /usr/bin/rebar3

ENV PATH /usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /opt/wrk

ENTRYPOINT ["/opt/includes/entrypoint.sh"]

CMD /bin/bash
