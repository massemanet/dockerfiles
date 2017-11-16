# Ubuntu Docker file for Jupyter/IJulia

# Version:v0.6.1
# docker build -t jupyter:0.6.1 <this_file>
# docker run -d -rm -p 8888:8888 -v /tmp/jupyter:/home/foo jupyter:0.6.1

FROM ubuntu:17.10

ENV JULIAREPO https://julialang.s3.amazonaws.com/bin/linux/x64/0.6
ENV JULIAREPO https://julialang-s3.julialang.org/bin/linux/x64/0.6
ENV JULIAVSN 0.6.1
EXPOSE 8888

# original version by:
# MAINTAINER Tanmay Mohapatra

RUN apt-get update \
 && apt-get upgrade \
        -y -o Dpkg::Options::="--force-confdef" \
        -o DPkg::Options::="--force-confold" \
 && apt-get install -y \
        build-essential \
        cmake \
        curl \
        file \
        gettext \
        gfortran \
        libc6 \
        libc6-dev \
        libgnutls30 \
        libncurses-dev \
        libpcre3-dev \
        libreadline-dev \
        libzmq3-dev \
        libzmq5 \
        man-db \
        msgpack-python \
        pkg-config \
        python \
        python-crypto \
        python-dev \
        python-git \
        python-isodate \
        python-jinja2 \
        python-m2crypto \
        python-pip \
        python-requests \
        python-setuptools \
        python-yaml \
        supervisor \
        unzip \
 && apt-get clean

# python
RUN pip install --upgrade \
    pyzmq PyDrive google-api-python-client jsonpointer jsonschema tornado \
    sphinx pygments nose readline mistune invoke 'notebook==4.2'

# Install julia
RUN mkdir -p /opt/julia-${JULIAVSN} && \
    curl -v -L ${JULIAREPO}/julia-${JULIAVSN}-linux-x86_64.tar.gz | \
        tar -C /opt/julia-${JULIAVSN} -x -z --strip-components=1 -f - && \
    ln -fs /opt/julia-${JULIAVSN} /opt/julia && \
    echo "PATH=\"$PATH:/opt/julia/bin\"" > /etc/environment && \
    echo "export PATH" >> /etc/environment && \
    echo "source /etc/environment" >> /root/.bashrc && \
    /opt/julia/bin/julia -e 'Pkg.add("IJulia")' && \
    /opt/julia/bin/julia -e 'Pkg.build("IJulia")'

RUN mkdir -p /home/jupyter
WORKDIR /home/jupyter

CMD jupyter notebook --ip=0.0.0.0 --no-browser
