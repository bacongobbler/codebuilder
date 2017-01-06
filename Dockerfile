FROM debian:jessie

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E1DF1F24 && \
	echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu xenial main" >> /etc/apt/sources.list && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		git \
		sudo \
		openssh-server \
		coreutils \
		tar \
		xz-utils && \
	mkdir -p /var/run/sshd && \
	rm -rf /etc/ssh/ssh_host* && \
    # cleanup
    apt-get autoremove -y && \
    apt-get clean -y

# install docker client
RUN curl https://get.docker.com/builds/Linux/x86_64/docker-1.12.2.tgz | tar xz && \
    mv docker/* /bin && \
    rm -rf docker

# install helm


COPY rootfs /

ENTRYPOINT ["/bin/entrypoint"]
CMD ["/usr/sbin/sshd", "-D", "-e"]
EXPOSE 2222
