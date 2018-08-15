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
     'using Pkg; \
      Pkg.add("PyCall"); \
      Pkg.add("CSV"); \
      Pkg.add("DataFrames"); \
      Pkg.add("IJulia"); \
      Pkg.add("LsqFit"); \
      Pkg.add("PyPlot"); \
      Pkg.add("LaTeXStrings"); \
      Pkg.add("Plots"); \
      Pkg.add("StatPlots"); \
      ENV["PYTHON"]=""; Pkg.build(); \
      using CSV; \
      using DataFrames; \
      using IJulia; \
      using LsqFit' \

RUN ln -s /root/.julia/packages/Conda/*/deps/usr /opt/conda

ENV PATH /opt/julia/bin:/opt/conda/bin:$PATH

# install Plots.jl
RUN /opt/julia/bin/julia -e \
     'using Plots; \
      using StatPlots; \
      pyplot()'
