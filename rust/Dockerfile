ARG FROM_IMAGE
FROM ${FROM_IMAGE}

# install rust (needs cc)
RUN curl -sSf https://sh.rustup.rs > /tmp/$$ \
 && chmod +x /tmp/$$ \
 && chmod +rx ~ \
 && /tmp/$$ -y

ENV PATH /home/dockis/.cargo/bin:$PATH

# cargo install racer
# cargo install rustsym
# cargo install rustfmt
# cargo install ripgrep
# rustup self update
# rustup update
# rustup component add rls-preview
# rustup component add rust-analysis
# rustup component add rust-src
