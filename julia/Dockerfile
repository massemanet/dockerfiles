FROM ubuntu:17.10

ARG JULIA_TARBALL

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
      libpython-dev \
      python3-matplotlib \
      python3-qtconsole \
      python3-notebook \
      unzip \
 && apt-get clean

RUN mkdir -p /opt/julia \
 && mkdir -p /home/julia \
 && curl -v -L ${JULIA_TARBALL} | \
        tar -C /opt/julia -x -z --strip-components=1 -f - \
 && /opt/julia/bin/julia -e 'Pkg.add("IJulia")     ; Pkg.build("IJulia")' \
 && /opt/julia/bin/julia -e 'Pkg.add("Plots")      ; Pkg.build("Plots")' \
 && /opt/julia/bin/julia -e 'Pkg.add("DataFrames") ; Pkg.build("DataFrames")' \
 && /opt/julia/bin/julia -e 'Pkg.add("RDatasets")  ; Pkg.build("RDatasets")' \
 && /opt/julia/bin/julia -e 'Pkg.add("StatPlots")  ; Pkg.build("StatPlots")'

ENV PYTHON python3
RUN /opt/julia/bin/julia -e 'Pkg.add("PyPlot") ; Pkg.build("PyPlot")' \
 && /opt/julia/bin/julia -e 'Pkg.add("GR")     ; Pkg.build("GR")'

EXPOSE 8888
WORKDIR /home/julia

CMD /bin/bash
