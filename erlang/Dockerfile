FROM ubuntu:17.10

RUN apt-get update \
 && apt-get upgrade -y \
      -o Dpkg::Options::="--force-confdef" \
      -o DPkg::Options::="--force-confold" \
 && apt-get install -y \
     apt-file bash-completion curl emacs \
 && apt-get clean

RUN mkdir -p /opt/erlang/tmp \
 && curl https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb > \
     /tmp/erlang-solutions_1.0_all.deb \
 && dpkg -i /tmp/erlang-solutions_1.0_all.deb \
 && apt-get install -y \
     erlang-common-test erlang-eunit erlang-dialyzer \
     erlang-mode erlang-parsetools erlang-dev

ADD bashrc           /root/.bashrc
ADD erlang           /root/.erlang
ADD user_default.erl /root/user_default.erl

ENV PATH /usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /opt/erlang/tmp

CMD /bin/bash
