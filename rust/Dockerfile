FROM basemanet:18.04

# install rust (needs cc)
RUN curl -sSf https://sh.rustup.rs > /tmp/$$ \
 && chmod +x /tmp/$$ \
 && chmod +rx ~ \
 && /tmp/$$ -y

ENV PATH /home/dockis/.cargo/bin:$PATH
