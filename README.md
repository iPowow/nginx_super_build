
Supernginx build
===

Nginx with bundled modules:
	* echo-nginx module
	* lua-nginx-module module
	* ngx_devel_kit module
	* set-misc-nginx-module module
	* encrypted-session-nginx-module module
	* headers-more-nginx-module module
	+ pcre
	+ openssl
	

### Dependencies

  - Docker (https://docs.docker.com/installation/)  

### Checkout the code and set it up

    git clone https://github.com/ipowow/nginx_super_build
    cd nginx_super_build

### Now you are ready to build your Nginx

    docker build -t nginx_super_build .
    docker run --rm nginx_super_build > supernginx

## Commit the binary to the nginx_super_binary repo: 

	git@bitbucket.org:ipowow/nginx_super_binary.git 


