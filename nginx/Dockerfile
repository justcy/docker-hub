FROM nginx:alpine

MAINTAINER justcy(https://github.com/justcy)

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && apk update \ 
&& apk add --no-cache ca-certificates tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

COPY ./nginx/nginx.conf /etc/nginx/