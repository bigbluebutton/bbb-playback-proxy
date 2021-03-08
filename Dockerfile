FROM ubuntu:18.04 AS playback-bionic-23-dev
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y language-pack-en \
    && update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
RUN apt-get update \
    && apt-get install -y software-properties-common curl net-tools nginx
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC86BB64 \
    && add-apt-repository ppa:rmescandon/yq
RUN apt-get update \
    && apt-get install -y yq
RUN curl -sL https://ubuntu.bigbluebutton.org/repo/bigbluebutton.asc | apt-key add - \
    && echo "deb https://ubuntu.bigbluebutton.org/bionic-23-dev bigbluebutton-bionic main" >/etc/apt/sources.list.d/bigbluebutton.list
RUN useradd --system --user-group --home-dir /var/bigbluebutton bigbluebutton
RUN touch /.dockerenv
RUN apt-get update \
    && apt-get download bbb-playback bbb-playback-presentation \
    && dpkg -i --force-depends *.deb


FROM amazonlinux
RUN yes | amazon-linux-extras install nginx1
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
RUN gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
 && gpg --batch --verify /tini.asc /sbin/tini
RUN chmod +x /sbin/tini
RUN yum update && yum -y install gettext
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log
COPY --from=playback-bionic-23-dev /etc/bigbluebutton/nginx /etc/bigbluebutton/nginx/
COPY --from=playback-bionic-23-dev /var/bigbluebutton/playback /var/bigbluebutton/playback/
COPY nginx /etc/nginx/
EXPOSE 80
ENV NGINX_HOSTNAME=localhost
CMD [ "/etc/nginx/start", "-g", "daemon off;" ]
