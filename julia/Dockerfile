FROM basemanet:18.04

ARG JULIA_TARBALL

RUN apt-get update \
 && apt-get install -y \
      build-essential \
      ca-certificates \
      imagemagick \
      inkscape \
      libpython-dev \
      libpython3-dev \
      pandoc \
      python3-matplotlib \
      python3-notebook \
      python3-qtconsole \
      texlive-xetex \
      unzip \
 && apt-get clean

# install julia from tarball
RUN mkdir -p /opt/julia \
 && curl -v -L ${JULIA_TARBALL} | \
      tar -C /opt/julia -x -z --strip-components=1 -f -

# install basic data science support for julia
RUN /opt/julia/bin/julia -e \
     'using Pkg;\
      Pkg.add("CSV");\
      Pkg.add("DataFrames");\
      Pkg.add("GLM");\
      Pkg.add("IJulia");\
      Pkg.add("LsqFit");\
      Pkg.add("RDatasets");\
      Pkg.build();\
      using CSV ; using DataFrames ; using GLM ;\
      using IJulia ; using LsqFit ; using StatsBase' \
 && ln -s /root/.julia/v* /opt/julia_local \
 && ln -s /opt/julia_local/Conda/deps/usr /opt/conda

ENV PATH /opt/julia/bin:/opt/conda/bin:$PATH
ENV JULIA_LOAD_PATH /opt/julia_local

# install Plots.jl
RUN /opt/julia/bin/julia -e \
     'using Pkg;\
      Pkg.add("Plots"); \
      Pkg.add("StatPlots"); \
      Pkg.add("GR"); \
      Pkg.add("PyPlot"); \
      ENV["PYTHON"]=""; \
      Pkg.build()' \
 && /opt/julia/bin/julia -e \
     'using Plots; \
      using StatPlots' \
 && /opt/julia/bin/julia -e \
     'using PyPlot' \
 && /opt/julia/bin/julia -e \
     'using GR'
