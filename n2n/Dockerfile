FROM justcy/alpine:latest

ARG N2N="https://github.com/meyerd/n2n"

ENV ALPINE_TOOLS="openssl-dev build-base make git cmake gcc libc-dev bsd-compat-headers linux-headers musl-dev"


RUN apk add $ALPINE_TOOLS && git clone $N2N && cd /n2n/n2n_v2 && mkdir build && cd build && cmake ./ ../ && make && make install && apk del $ALPINE_TOOLS && rm -rf /n2n    

