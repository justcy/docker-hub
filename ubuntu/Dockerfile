# @description php image base on the alpine edge
#                       some information
# ------------------------------------------------------------------------------------
# @link https://hub.docker.com/_/alpine/      alpine image
# @link https://hub.docker.com/_/php/         php image
# @link https://github.com/docker-library/php php dockerfiles
# ------------------------------------------------------------------------------------
# @build-example docker build . -f Dockerfile -t mydev/ubuntu:1.0.0
# 
FROM ubuntu:latest
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y tzdata \
    && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get update && apt-get install -y \ 
ssh \
build-essential \
gcc \
g++ \
gdb \ 
clang \
cmake \
rsync \
tar \
python \
vim \
automake \ 
openssh-client \
openssh-server \
pkg-config \ 
libxml2-dev \
libsqlite3-dev \
&& apt-get clean
RUN apt-get install sudo

RUN echo "#!/bin/bash\nadduser deploy << EOF\npassword\npassword\ndeploy\n\n\n\nY\nEOF" >> create_deploy.sh \
    && chmod 755 create_deploy.sh \
    && ./create_deploy.sh \
    && gpasswd -a deploy sudo \
    && rm create_deploy.sh \
    && chmod 644 /etc/sudoers \
    && echo "deploy ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && passwd deploy
