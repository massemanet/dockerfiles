FROM ubuntu:17.10

ARG JULIA_TARBALL

RUN apt-get update \
 && apt-get install -y \
      bash-completion \
      build-essential \
      ca-certificates \
      curl \
      git \
      gosu \
      imagemagick \
      inkscape \
      libpython-dev \
      libpython3-dev \
      pandoc \
      python3-matplotlib \
      python3-notebook \
      python3-qtconsole \
      sudo \
      texlive-xetex \
      tmux \
      unzip \
 && apt-get clean

# install julia from tarball
RUN umask 000 \
 && chmod +rwx /root /opt \
 && mkdir -p /opt/julia \
 && mkdir -p /opt/wrk \
 && curl -v -L ${JULIA_TARBALL} | \
      tar -C /opt/julia -x -z --strip-components=1 -f -

# install basic data science support for julia
RUN /opt/julia/bin/julia -e \
     'Pkg.add("CSV");\
      Pkg.add("IJulia");\
      Pkg.add("DataFrames");\
      Pkg.add("RDatasets");\
      Pkg.add("StatPlots");\
      Pkg.add("Plots");\
      Pkg.add("GR");\
      ENV["PYTHON"]="python3";\
      Pkg.add("PyPlot");\
      Pkg.build();\
      using IJulia ; using Plots ; using PyPlot ; using CSV ; using DataFrames' \
 && /opt/julia/bin/julia -e \
    'using GR' \
 && ln -s /root/.julia/v* /opt/julia_local \
 && ln -s /opt/julia_local/Conda/deps/usr /opt/conda

# the entrypoint will move these files after it has created a user.
COPY includes/ /opt/includes/

# need to make sure /root is readable in case we change user
RUN /opt/includes/fix-perms.sh

ENV PATH /opt/julia/bin:/opt/conda/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV JULIA_LOAD_PATH /opt/julia_local

WORKDIR /opt/wrk

ENTRYPOINT ["/opt/includes/entrypoint.sh"]

CMD /bin/bash
