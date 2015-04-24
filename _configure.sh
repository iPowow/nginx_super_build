#!/bin/bash

EXTRA_MODULES=
./configure --with-cc-opt="-Wno-deprecated-declarations" \
--with-pcre \
--with-http_ssl_module \
$EXTRA_MODULES
