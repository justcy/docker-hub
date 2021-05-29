FROM centos:centos7.4.1708

MAINTAINER justcy

RUN yum -y --nogpgcheck install gcc gcc-c++ gdb rsync kernel-devel make cmake automake libstdc++-devel libstdc++-static \
&& yum -y --nogpgcheck install openssl-devel gperftools-libs \
&& yum -y --nogpgcheck install psmisc openssh-server sudo epel-release \
&& yum -y --nogpgcheck install vim tar git ctags \
&& echo "root:develop" | chpasswd \
&& sed -ri 's/^#PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
&& sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config \
&& ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key \
&& ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
