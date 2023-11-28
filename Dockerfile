FROM ubuntu:latest

ENV HUGO_VERSION=0.114.0

RUN apt update && apt install -y npm wget

RUN wget -O hugo.deb https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb \
          && dpkg -i hugo.deb

WORKDIR /usr/src/app

COPY . /usr/src/app/

CMD ["hugo"]