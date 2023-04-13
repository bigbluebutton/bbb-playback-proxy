FROM ubuntu:20.04 AS bbb-playback
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y language-pack-en \
    && update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
RUN apt-get update \
    && apt-get install -y software-properties-common curl net-tools nginx
RUN add-apt-repository -y ppa:bigbluebutton/support
RUN apt-get update \
    && apt-get install -y yq
RUN curl -sL https://ubuntu.bigbluebutton.org/repo/bigbluebutton.asc | apt-key add - \
    && echo "deb https://ubuntu.bigbluebutton.org/focal-260 bigbluebutton-focal main" >/etc/apt/sources.list.d/bigbluebutton.list
RUN useradd --system --user-group --home-dir /var/bigbluebutton bigbluebutton
RUN touch /.dockerenv
RUN apt-get update
RUN apt-get download bbb-playback bbb-playback-presentation bbb-playback-podcast bbb-playback-screenshare bbb-playback-video \
    && dpkg -i --force-depends ./*.deb

FROM alpine:3.16 AS bbb-playback-proxy
RUN apk add --no-cache nginx tini gettext \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log
RUN rm /etc/nginx/http.d/default.conf
COPY --from=bbb-playback /usr/share/bigbluebutton/nginx/ /usr/share/bigbluebutton/nginx/
COPY --from=bbb-playback /var/bigbluebutton/playback /var/bigbluebutton/playback/
COPY nginx/start /etc/nginx/start
COPY nginx/dhparam.pem /etc/nginx/dhparam.pem
COPY nginx/conf.d /etc/nginx/http.d/
EXPOSE 80
EXPOSE 443
ENV NGINX_HOSTNAME=localhost
CMD [ "/etc/nginx/start", "-g", "daemon off;" ]
