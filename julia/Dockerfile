FROM ubuntu:17.10

ENV JULIAREPO https://julialang-s3.julialang.org/bin/linux/x64/0.6
ENV JULIAVSN 0.6.1

RUN apt-get update \
 && apt-get upgrade \
        -y \
        -o Dpkg::Options::="--force-confdef" \
        -o DPkg::Options::="--force-confold"

RUN apt-get install -y \
      build-essential \
      ca-certificates \
      curl \
      libpython3-dev \
      python3-matplotlib \
      python3-qtconsole \
      python3-notebook \
      unzip \
 && apt-get clean

RUN mkdir -p /opt/julia \
 && curl -v -L ${JULIAREPO}/julia-${JULIAVSN}-linux-x86_64.tar.gz | \
        tar -C /opt/julia -x -z --strip-components=1 -f - \
 && /opt/julia/bin/julia -e 'Pkg.add("IJulia")' \
 && /opt/julia/bin/julia -e 'Pkg.add("PyPlot")' \
 && /opt/julia/bin/julia -e 'Pkg.add("Plots")' \
 && /opt/julia/bin/julia -e 'Pkg.add("DataFrames")' \
 && /opt/julia/bin/julia -e 'Pkg.add("RDatasets")' \
 && /opt/julia/bin/julia -e 'Pkg.add("StatPlots")' \
 && /opt/julia/bin/julia -e 'Pkg.add("GR")' \
 && /opt/julia/bin/julia -e 'Pkg.build("IJulia")' \
 && /opt/julia/bin/julia -e 'Pkg.build("PyPlot")' \
 && /opt/julia/bin/julia -e 'Pkg.build("Plots")' \
 && /opt/julia/bin/julia -e 'Pkg.build("DataFrames")' \
 && /opt/julia/bin/julia -e 'Pkg.build("RDatasets")' \
 && /opt/julia/bin/julia -e 'Pkg.build("StatPlots")' \
 && /opt/julia/bin/julia -e 'Pkg.build("GR")' \
 && mkdir -p /home/julia

EXPOSE 8888
WORKDIR /home/julia

CMD /root/.julia/v0.6/Conda/deps/usr/bin/jupyter-qtconsole --kernel julia-0.6
