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
      libpython3-dev \
      libpython-dev \
      pandoc \
      python3-matplotlib \
      python3-qtconsole \
      python3-notebook \
      texlive-xetex \
      unzip \
 && apt-get clean \
 && mkdir -p /opt/wrk

# the entrypoint will move these files after it has created a user.
COPY includes/ /opt/includes/

# install julia with basic data science support
RUN mkdir -p /opt/julia \
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
 && ln -s /root/.julia/v* /opt/julia_local \
 && ln -s /opt/julia_local/Conda/deps/usr /opt/conda

EXPOSE 8888

ENV PATH /opt/julia/bin:/opt/conda/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV JULIA_LOAD_PATH /opt/julia_local

WORKDIR /opt/wrk

ENTRYPOINT ["/opt/includes/entrypoint.sh"]

CMD /bin/bash
