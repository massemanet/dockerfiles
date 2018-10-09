FROM basemanet:18.04

RUN sudo apt-get update \
 && sudo add-apt-repository ppa:lyzardking/ubuntu-make \
 && sudo apt-get update \
 && sudo apt-get install -y \
     imagemagick \
     inkscape \
     jupyter-nbconvert \
     jupyter-notebook \
     pandoc \
     python3-matplotlib \
     python3-numpy \
     python3-pandas \
     python3-sklearn-lib \
     texlive-xetex \
     ubuntu-make \
 && sudo apt-get clean

RUN ((echo "/opt/pycharm") | umake ide pycharm) \
 && ln -s /opt/pycharm/bin/pycharm.sh /usr/bin

COPY includes/ /opt/includes/

RUN /opt/includes/fetch.atom
