FROM centos:centos8
LABEL "maintainer"="Marco Mornati <marco@mornati.net>"
LABEL "com.github.actions.name"="RPM Builder"
LABEL "com.github.actions.description"="Build RPM using RedHat Mock"
LABEL "com.github.actions.icon"="pocket"
LABEL "com.github.actions.color"="green"

RUN yum -y --setopt="tsflags=nodocs" update && \
	yum -y --setopt="tsflags=nodocs" install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
	yum -y --setopt="tsflags=nodocs" install mock rpm-sign expect rpmdevtools && \
	yum clean all && \
	rm -rf /var/cache/yum/

#Configure users
RUN useradd -u 1000 -G mock builder && \
	chmod g+w /etc/mock/*.cfg

VOLUME ["/rpmbuild"]

ONBUILD COPY mock /etc/mock

# create mock cache on external volume to speed up build
RUN install -g mock -m 2775 -d /rpmbuild/cache/mock
RUN echo "config_opts['cache_topdir'] = '/rpmbuild/cache/mock'" >> /etc/mock/site-defaults.cfg

ADD ./build-rpm.sh /build-rpm.sh
RUN chmod +x /build-rpm.sh
ADD ./srpm-tool-get-sources /srpm-tool-get-sources
RUN chmod +x /srpm-tool-get-sources
#RUN setcap cap_sys_admin+ep /usr/sbin/mock
ADD ./rpm-sign.exp /rpm-sign.exp
RUN chmod +x /rpm-sign.exp

CMD ["/build-rpm.sh"]
