# Ubuntu Docker file for Julia
# Version:v0.6.1
# docker build -t julia:0.6.1 <this_file>
# docker run -d -rm -p 8888:8888 -v /tmp/julia:/home/foo julia:0.6.1

FROM ubuntu:17.10

ENV JULIAREPO https://julialang-s3.julialang.org/bin/linux/x64/0.6
ENV JULIAVSN 0.6.1

RUN apt-get update \
 && apt-get upgrade \
        -y \
        -o Dpkg::Options::="--force-confdef" \
        -o DPkg::Options::="--force-confold"

RUN apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      curl \
      file \
      gettext \
      gfortran \
      libgnutls30 \
      libncurses-dev \
      libpangoxft-1.0-0 \
      libpcre3-dev \
      libreadline-dev \
      libzmq3-dev \
      libzmq5 \
      unzip \
 && apt-get clean

RUN mkdir -p /opt/julia-${JULIAVSN} && \
    curl -v -L ${JULIAREPO}/julia-${JULIAVSN}-linux-x86_64.tar.gz | \
        tar -C /opt/julia-${JULIAVSN} -x -z --strip-components=1 -f - && \
    ln -fs /opt/julia-${JULIAVSN} /opt/julia && \
    mkdir -p /home/julia

WORKDIR /home/julia

CMD /opt/julia/bin/julia
