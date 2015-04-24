FROM centos:centos6
MAINTAINER Matt Lohier "mlohier@ipowow.com"

# Install some packages we will need
RUN yum -y install yum-utils \
        gcc \
        gcc-c++ \
        git \
        zlib-devel \
        nspr-devel \
        nss-devel \
        pcre-devel \
        lua-devel \
        openssl-devel

# Install nginx
RUN cd /tmp && \
    git clone https://github.com/nginx/nginx.git && \
    cd nginx && \
    git checkout v1.8.0 && \
    rm -rf .git*

# Install a makefile
ADD _configure.sh /tmp/nginx/

## --- iPowow NGINX customisations ---

# echo-nginx module
RUN cd /tmp && \
    git clone https://github.com/openresty/echo-nginx-module.git && \
    cd echo-nginx-module && \
    git checkout v0.57 && \
    rm -rf .git* && \
    sed -i '/$EXTRA_MODULES/i--add-module=/tmp/echo-nginx-module \\' /tmp/nginx/_configure.sh

# lua-nginx-module module
RUN cd /tmp && \
    git clone https://github.com/openresty/lua-nginx-module.git && \
    cd lua-nginx-module && \
    git checkout v0.9.15 && \
    rm -rf .git* && \
    sed -i '/$EXTRA_MODULES/i--add-module=/tmp/lua-nginx-module \\' /tmp/nginx/_configure.sh

# ngx_devel_kit module
RUN cd /tmp && \
    git clone https://github.com/simpl/ngx_devel_kit.git && \
    cd ngx_devel_kit && \
    git checkout v0.2.19 && \
    rm -rf .git* && \
    sed -i '/$EXTRA_MODULES/i--add-module=/tmp/ngx_devel_kit \\' /tmp/nginx/_configure.sh

# set-misc-nginx-module module
RUN cd /tmp && \
    git clone https://github.com/openresty/set-misc-nginx-module.git && \
    cd set-misc-nginx-module && \
    git checkout master && \
    rm -rf .git* && \
    sed -i '/$EXTRA_MODULES/i--add-module=/tmp/set-misc-nginx-module \\'  /tmp/nginx/_configure.sh

# encrypted-session-nginx-module module
RUN cd /tmp && \
    git clone https://github.com/openresty/encrypted-session-nginx-module.git && \
    cd encrypted-session-nginx-module && \
    git checkout master && \
    rm -rf .git* && \
    sed -i '/$EXTRA_MODULES/i--add-module=/tmp/encrypted-session-nginx-module \\'  /tmp/nginx/_configure.sh

# headers-more-nginx-module module
RUN cd /tmp && \
    git clone https://github.com/openresty/headers-more-nginx-module.git && \
    cd headers-more-nginx-module && \
    git checkout v0.26 && \
    rm -rf .git* && \
    sed -i '/$EXTRA_MODULES/i--add-module=/tmp/headers-more-nginx-module \\'  /tmp/nginx/_configure.sh

# nginx-upload-module
#RUN cd /tmp && \
#    git clone https://github.com/vkholodkov/nginx-upload-module.git && \
#    cd nginx-upload-module && \
#    git checkout 2.2 && \
#    rm -rf .git* && \
#    sed -i '/$EXTRA_MODULES/i--add-module=/tmp/nginx-upload-module \\'  /tmp/nginx/_configure.sh

RUN cat /tmp/nginx/_configure.sh

## --- END iPowow NGINX customisations ---

# Build nginx (with modules we have just added)
RUN cd /tmp/nginx/ && \
    ./_configure.sh && \
    make && \
    make install

# Check that everything went ok listing nginx compilation flags
RUN cd /lib64 && \
    ln -s libpcre.so.0 libpcre.so.1 && \
    /usr/local/nginx/sbin/nginx -V

CMD ["cat", "/usr/local/nginx/sbin/nginx"]

