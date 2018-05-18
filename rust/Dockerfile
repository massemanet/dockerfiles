ARG BASE_IMAGE

FROM ${BASE_IMAGE}

# install rust (needs cc)
RUN apt-get install -y build-essential \
 && curl -sSf https://sh.rustup.rs > /tmp/$$ \
 && chmod +x /tmp/$$ \
 && /tmp/$$ -y

ENV PATH /root/.cargo/bin:$PATH
