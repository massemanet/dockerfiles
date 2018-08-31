FROM basemanet:18.04

# install erlang from erlang solutions
# we only install a subset of the packages
# we get a stock rebar3 as well
RUN curl https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb > \
     /tmp/erlang-solutions_1.0_all.deb \
 && dpkg -i /tmp/erlang-solutions_1.0_all.deb \
 && apt-get update \
 && apt-get install -y \
     erlang-common-test erlang-eunit erlang-dialyzer \
     erlang-mode erlang-parsetools erlang-dev \
 && curl https://s3.amazonaws.com/rebar3/rebar3 > /usr/bin/rebar3 \
 && chmod +x /usr/bin/rebar3

RUN cd ~ \
 && git clone https://github.com/massemanet/distel \
 && cd distel \
 && git checkout 2018 \
 && make

RUN cd ~ \
 && git clone https://github.com/massemanet/distel-completion

RUN cd ~ \
 && git clone https://github.com/massemanet/trane \
 && make -C trane

RUN cd ~ \
 && git clone https://github.com/massemanet/redbug \
 && cd redbug \
 && git checkout v2.0 \
 && make

COPY includes/ /opt/includes
