ARG BASE_IMAGE

FROM ${BASE_IMAGE}

# install rust (needs cc)
RUN curl -sSf https://sh.rustup.rs > /tmp/$$ \
 && chmod +x /tmp/$$ \
 && chmod +rx /root \
 && /tmp/$$ -y

ENV PATH /root/.cargo/bin:$PATH
