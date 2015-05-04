#!/bin/bash

./configure --with-cc-opt="-Wno-deprecated-declarations" \
--with-ld-opt="-Bstatic" \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--pid-path=/var/run/nginx.pid \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--with-openssl=$BPATH/$OPENSSL_VERSION \
--with-pcre=$BPATH/$PCRE_VERSION \
--with-http_ssl_module \
--with-http_spdy_module \
--with-file-aio \
--with-ipv6 \
--with-http_gzip_static_module \
--with-http_stub_status_module \
--without-mail_pop3_module \
--without-mail_smtp_module \
--without-mail_imap_module \