FROM basemanet:18.04

ARG GO_TARBALL

# install julia from tarball
RUN mkdir -p /opt/go \
 && curl -v -L ${GO_TARBALL} | \
      tar -C /opt/go -x -z --strip-components=1 -f -

ENV GOROOT /opt/go
ENV PATH $GOROOT/bin:$PATH
