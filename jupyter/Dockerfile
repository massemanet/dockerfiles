# Ubuntu Docker file for Julia
# Version:v0.6.0
# docker build -t julia:0.6.0 <this_file>
# docker run -d -rm -p 8888:8888 -v /tmp/julia:/home/foo julia:0.6.0

FROM ubuntu:17.10

ENV JULIAREPO https://julialang.s3.amazonaws.com/bin/linux/x64/0.6
ENV JULIAVSN 0.6.0
EXPOSE 8888

# original version by:
# MAINTAINER Tanmay Mohapatra

RUN apt-get update \
 && apt-get upgrade \
        -y -o Dpkg::Options::="--force-confdef" \
        -o DPkg::Options::="--force-confold" \
 && apt-get install -y \
        man-db \
        libc6 \
        libc6-dev \
        build-essential \
        wget \
        curl \
        file \
        tmux \
        unzip \
        pkg-config \
        cmake \
        gfortran \
        gettext \
        libreadline-dev \
        libncurses-dev \
        libpcre3-dev \
        libgnutls30 \
        libzmq3-dev \
        libzmq5 \
        python \
        python-yaml \
        python-m2crypto \
        python-crypto \
        msgpack-python \
        python-dev \
        python-setuptools \
        supervisor \
        python-jinja2 \
        python-requests \
        python-isodate \
        python-git \
        python-pip \
 && apt-get clean

RUN pip install --upgrade pyzmq PyDrive google-api-python-client jsonpointer \
        jsonschema tornado sphinx pygments nose readline mistune invoke
RUN pip install 'notebook==4.2'

# Install julia
RUN mkdir -p /opt/julia-${JULIAVSN} && \
    curl -s -L ${JULIAREPO}/julia-${JULIAVSN}-linux-x86_64.tar.gz | \
        tar -C /opt/julia-${JULIAVSN} -x -z --strip-components=1 -f - && \
    ln -fs /opt/julia-${JULIAVSN} /opt/julia && \
    echo "PATH=\"$PATH:/opt/julia/bin\"" > /etc/environment && \
    echo "export PATH" >> /etc/environment && \
    echo "source /etc/environment" >> /root/.bashrc && \
    /opt/julia/bin/julia -e 'Pkg.add("IJulia")' && \
    /opt/julia/bin/julia -e 'Pkg.build("IJulia")'

RUN mkdir -p /home/julia
WORKDIR /home/julia

CMD jupyter notebook --ip=0.0.0.0 --no-browser
