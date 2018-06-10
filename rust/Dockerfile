FROM basemanet:18.04

# install rust (needs cc)
RUN curl -sSf https://sh.rustup.rs > /tmp/$$ \
 && chmod +x /tmp/$$ \
 && chmod +rx /root \
 && /tmp/$$ -y

ENV PATH /root/.cargo/bin:$PATH
