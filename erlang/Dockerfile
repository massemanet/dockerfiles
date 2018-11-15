FROM basemanet:18.10

# install erlang from erlang solutions
# we only install a subset of the packages
# we get a stock rebar3 as well
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

COPY includes/ /opt/includes

RUN cd ~ \
 && git clone https://github.com/massemanet/distel \
 && cd distel \
 && git checkout 2018 \
 && make

RUN cd ~ \
 && git clone https://github.com/massemanet/distel-completion

RUN cd ~ \
 && git clone https://github.com/massemanet/redbug \
 && cd redbug \
 && make
