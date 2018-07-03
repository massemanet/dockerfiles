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
 && chmod +x /usr/bin/rebar3 \
 && cd $HOME/.emacs.d/.cask/*/elpa/edts-*/lib/edts \
 && make deps \
 && sed -i 's/warnings_as_errors,//g' ../meck/rebar.config \
 && make -C ../..

COPY includes/ /opt/includes
