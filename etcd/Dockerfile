FROM alpine:latest
ENV ETCD_VER=v3.5.0
ENV ALPINE_TOOLS="ca-certificates openssl tar"
RUN apk add $ALPINE_TOOLS && \
    wget https://github.com//etcd-io/etcd/releases/download/$ETCD_VER/etcd-$ETCD_VER-linux-amd64.tar.gz && \
    tar xzvf etcd-$ETCD_VER-linux-amd64.tar.gz && \
    mv etcd-$ETCD_VER-linux-amd64/etcd* /bin/ && \
    apk del --purge $ALPINE_TOOLS && \
    rm -rf etcd-$ETCD_VER-linux-amd64* /var/cache/apk/*
VOLUME      /data
EXPOSE      2379 2380 4001 7001
ADD         run.sh /bin/run.sh
ENTRYPOINT  ["/bin/sh", "/bin/run.sh"]
 
