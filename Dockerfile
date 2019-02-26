FROM alpine
MAINTAINER Raúl Cumplido <raulcumplido@gmail.com>

RUN apk --no-cache add \
    ca-certificates \
    curl 

ENV HUGO_VERSION=0.54.0

RUN curl -sSL https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz | tar -vxz && \
    mv hugo /usr/local/bin/hugo

WORKDIR /usr/src/app

COPY . /usr/src/app/

CMD ["hugo"]