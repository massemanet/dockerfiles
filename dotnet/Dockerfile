ARG FROM_IMAGE
FROM ${FROM_IMAGE}

# install dotnet
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | \
      gpg --dearmor > /tmp/microsoft.asc.gpg \
 && sudo mv /tmp/microsoft.asc.gpg /etc/apt/trusted.gpg.d \
 && wget -qO- https://packages.microsoft.com/config/ubuntu/$(grep RELEASE /etc/lsb-release | \
      cut -f2 -d"=")/prod.list > /tmp/prod.list \
 && sudo mv /tmp/prod.list /etc/apt/sources.list.d/microsoft-prod.list \
 && sudo apt-get update \
 && sudo apt search dotnet-sdk | \
      grep -Eo "dotnet-sdk-[0-9]+\.[0-9]+\.[0-9]+/" | \
      sort -V | \
      tail -n1 | \
      cut -f1 -d"/" | \
      xargs sudo apt-get install -y
