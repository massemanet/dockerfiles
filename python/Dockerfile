ARG BASE_IMAGE

FROM ${BASE_IMAGE}

RUN apt-get update \
 && apt-get install -y software-properties-common \
 && add-apt-repository ppa:webupd8team/atom \
 && add-apt-repository ppa:lyzardking/ubuntu-make \
 && apt-get update \
 && apt-get install -y \
     atom \
     imagemagick \
     inkscape \
     pandoc \
     python3-matplotlib \
     python3-notebook \
     python3-numpy \
     python3-pandas \
     python3-sklearn-lib \
     texlive-xetex \
     ubuntu-make \
 && apt-get clean

RUN ((echo "/opt/pycharm") | umake ide pycharm) \
 && ln -s /opt/pycharm/bin/pycharm.sh /usr/bin
