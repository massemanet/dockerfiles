FROM basemanet:18.04

RUN apt-get update \
 && apt-get install -y \
      apt-transport-https \
      wget \
 && apt-get clean \
 && mkdir -p /opt/wrk

# install dotnet
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | \
      gpg --dearmor > microsoft.asc.gpg \
 && mv microsoft.asc.gpg /etc/apt/trusted.gpg.d \
 && wget -q https://packages.microsoft.com/config/ubuntu/$(grep RELEASE /etc/lsb-release | cut -f2 -d"=")/prod.list \
 && mv prod.list /etc/apt/sources.list.d/microsoft-prod.list \
 && apt-get update \
 && apt search dotnet-sdk | \
      grep -Eo "dotnet-sdk-[0-9]+\.[0-9]+\.[0-9]+/" | \
      sort -V | \
      tail -n1 | \
      cut -f1 -d"/" | \
      xargs apt-get install -y
