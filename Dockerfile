FROM phusion/baseimage:0.9.16
MAINTAINER Matt Lohier "mlohier@ipowow.com"

# Install some packages we will need
RUN apt-get update && \
    apt-get dist-upgrade -y

RUN apt-get install -y \
        build-essential \
        wget \
        git \
        zlib1g-dev \
        liblua5.1

# define the desired versions
ENV NGINX_VERSION=nginx-1.8.0 \
    OPENSSL_VERSION=openssl-1.0.2d \
    PCRE_VERSION=pcre-8.37

# path to download location
ENV NGINX_SOURCE http://nginx.org/download/
ENV OPENSSL_SOURCE https://www.openssl.org/source/
ENV PCRE_SOURCE ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/

# build path
ENV BPATH /usr/src

# refer to http://nginx.org/en/pgp_keys.html
RUN gpg --keyserver keys.gnupg.net --recv-key \
    F5806B4D \
    A524C53E \
    A1C052F8 \
    2C172083 \
    7ADB39A8 \
    6C7E5E82 \
    7BD9BF62
    
# refer to https://www.openssl.org/about/
RUN gpg --keyserver keys.gnupg.net --recv-key \
    49A563D9 \
    FA40E9E2 \
    2118CF83 \
    1FE8E023 \
    0E604491 \
    49A563D9 \
    FA40E9E2 \
    41FBF7DD \
    9C58A66D \
    2118CF83 \
    CE69424E \
    5A6A9B85 \
    1FE8E023 \
    41C25E5D \
    5C51B27C \
    E18C1C32
    
# Philip Hazel's public GPG key for pcre
RUN gpg --keyserver keys.gnupg.net --recv-key FB0F43D8

# download source packages and signatures
RUN cd $BPATH \
    && wget $PCRE_SOURCE$PCRE_VERSION.tar.gz \
    && wget $PCRE_SOURCE$PCRE_VERSION.tar.gz.sig \
    && wget $OPENSSL_SOURCE$OPENSSL_VERSION.tar.gz \
    && wget $OPENSSL_SOURCE$OPENSSL_VERSION.tar.gz.asc \
    && wget $NGINX_SOURCE$NGINX_VERSION.tar.gz \
    && wget $NGINX_SOURCE$NGINX_VERSION.tar.gz.asc

# verify and and extract
RUN cd $BPATH \
    && gpg --verify $PCRE_VERSION.tar.gz.sig \
    && gpg --verify $OPENSSL_VERSION.tar.gz.asc \
    && gpg --verify $NGINX_VERSION.tar.gz.asc \
    && tar xzf $PCRE_VERSION.tar.gz \
    && tar xzf $OPENSSL_VERSION.tar.gz \
    && tar xzf $NGINX_VERSION.tar.gz \
    && rm *.tar.gz*

# Install a makefile
ADD _configure.sh $BPATH/$NGINX_VERSION/

## --- iPowow NGINX customisations ---

# echo-nginx module
RUN cd /tmp && \
    git clone https://github.com/openresty/echo-nginx-module.git && \
    cd echo-nginx-module && \
    git checkout v0.58 && \
    rm -rf .git* && \
    { \
        echo '--add-module=/tmp/echo-nginx-module \\'; \
    } >> $BPATH/$NGINX_VERSION/_configure.sh

# lua-nginx-module module
RUN cd /tmp && \
    git clone https://github.com/openresty/lua-nginx-module.git && \
    cd lua-nginx-module && \
    git checkout v0.9.16 && \
    rm -rf .git* && \
    { \
        echo '--add-module=/tmp/lua-nginx-module \\'; \
    } >> $BPATH/$NGINX_VERSION/_configure.sh

# ngx_devel_kit module
RUN cd /tmp && \
    git clone https://github.com/simpl/ngx_devel_kit.git && \
    cd ngx_devel_kit && \
    git checkout v0.2.19 && \
    rm -rf .git* && \
    { \
        echo '--add-module=/tmp/ngx_devel_kit \\'; \
    } >> $BPATH/$NGINX_VERSION/_configure.sh

# set-misc-nginx-module module
RUN cd /tmp && \
    git clone https://github.com/openresty/set-misc-nginx-module.git && \
    cd set-misc-nginx-module && \
    git checkout v0.29 && \
    rm -rf .git* && \
    { \
        echo '--add-module=/tmp/set-misc-nginx-module \\'; \
    } >> $BPATH/$NGINX_VERSION/_configure.sh

# encrypted-session-nginx-module module
RUN cd /tmp && \
    git clone https://github.com/openresty/encrypted-session-nginx-module.git && \
    cd encrypted-session-nginx-module && \
    git checkout v0.04 && \
    rm -rf .git* && \
    { \
        echo '--add-module=/tmp/encrypted-session-nginx-module \\'; \
    } >> $BPATH/$NGINX_VERSION/_configure.sh

# headers-more-nginx-module module
RUN cd /tmp && \
    git clone https://github.com/openresty/headers-more-nginx-module.git && \
    cd headers-more-nginx-module && \
    git checkout v0.261 && \
    rm -rf .git* && \
    { \
        echo '--add-module=/tmp/headers-more-nginx-module \\'; \
    } >> $BPATH/$NGINX_VERSION/_configure.sh

# nginx-upload-module
#RUN cd /tmp && \
#    git clone https://github.com/vkholodkov/nginx-upload-module.git && \
#    cd nginx-upload-module && \
#    git checkout 2.2 && \
#    rm -rf .git* && \
#    sed -i '/$EXTRA_MODULES/i--add-module=/tmp/nginx-upload-module \\'  /tmp/nginx/_configure.sh

## --- iPowow NGINX customisations (end) ---

# Build nginx (with modules we have just added)

RUN cat $BPATH/$NGINX_VERSION/_configure.sh

RUN cd $BPATH/$NGINX_VERSION && \
    ./_configure.sh && \
    make && \
    make install

# Check that everything went ok listing nginx compilation flags
RUN cd /lib64 && \
    /usr/sbin/nginx -V && \
    ldd /usr/sbin/nginx

CMD ["cat", "/usr/sbin/nginx"]
