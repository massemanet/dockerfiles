FROM ubuntu:17.10

ARG JULIA_TARBALL

RUN apt-get update \
 && apt-get upgrade -y \
      -o Dpkg::Options::="--force-confdef" \
      -o DPkg::Options::="--force-confold" \
 && apt-get install -y \
      build-essential \
      ca-certificates \
      curl \
      emacs \
      libpython3-dev \
      libpython-dev \
      pandoc \
      python3-matplotlib \
      python3-qtconsole \
      python3-notebook \
      sudo \
      texlive \
      unzip \
 && apt-get clean

RUN mkdir -p /opt/julia/tmp \
 && curl -v -L ${JULIA_TARBALL} | \
      tar -C /opt/julia -x -z --strip-components=1 -f - \
 && /opt/julia/bin/julia -e \
     'Pkg.add("CSV")        ; Pkg.build("CSV") ;\
      Pkg.add("IJulia")     ; Pkg.build("IJulia") ;\
      Pkg.add("Plots")      ; Pkg.build("Plots") ;\
      Pkg.add("DataFrames") ; Pkg.build("DataFrames") ;\
      Pkg.add("RDatasets")  ; Pkg.build("RDatasets") ;\
      Pkg.add("StatPlots")  ; Pkg.build("StatPlots") ;\
      Pkg.add("GR")         ; Pkg.build("GR") ;\
      ENV["PYTHON"]="python3";\
      Pkg.add("PyPlot")     ; Pkg.build("PyPlot")' \
 && ln -s .julia/*/Conda/deps/usr /opt/conda

EXPOSE 8888

WORKDIR /opt/julia/tmp
ENV JULIA_LOAD_PATH /root/.julia/v0.6
ENV PATH /opt/julia/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CMD /bin/bash
