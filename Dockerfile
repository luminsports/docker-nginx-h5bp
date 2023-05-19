ARG NGINX_VERSION=1.24.0

FROM nginx:$NGINX_VERSION-alpine as builder

ARG NGINX_VERSION=1.24.0
ARG HEADERS_MORE_VERSION=0.34

RUN apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main nginx-mod-http-headers-more \
    && apk add --no-cache --virtual .build-deps \
        gcc \
        make \
        libc-dev \
        g++ \
        openssl-dev \
        linux-headers \
        pcre-dev \
        zlib-dev \
        libtool \
        automake \
        autoconf

RUN cd /opt \
    && wget -O - "https://github.com/openresty/headers-more-nginx-module/archive/refs/tags/v${HEADERS_MORE_VERSION}.tar.gz" | tar zxfv - \
    && mv /opt/headers-more-nginx-module-$HEADERS_MORE_VERSION /opt/headers-more-nginx-module \
    && wget -O - "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" | tar zxfv - \
    && mv /opt/nginx-$NGINX_VERSION /opt/nginx \
    && cd /opt/nginx \
    && ./configure --with-compat --add-dynamic-module=/opt/headers-more-nginx-module \
    && make modules \
    && apk del .build-deps \
    && rm -rf /usr/share/man/* /usr/includes/* /var/cache/apk/* /tmp/*

FROM nginx:$NGINX_VERSION-alpine

COPY --from=builder --chmod=644 /opt/nginx/objs/ngx_http_headers_more_filter_module.so /usr/lib/nginx/modules/ngx_http_headers_more_filter_module.so
COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./index.html /usr/share/nginx/html/index.html
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./mime.types /etc/nginx/mime.types
COPY ./fastcgi_params /etc/nginx/fastcgi_params
COPY ./h5bp /etc/nginx/h5bp

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

