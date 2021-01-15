from registry
maintainer Shipyard Project "http://shipyard-project.com"
run apt-get update
run apt-get -y upgrade
run apt-get install -y apache2-utils supervisor python-setuptools make g++ libpcre3-dev wget libssl-dev libreadline-dev perl redis-server
run wget http://openresty.org/download/ngx_openresty-1.4.3.6.tar.gz -O /tmp/nginx.tar.gz
run (cd /tmp && tar zxf nginx.tar.gz && cd ngx_* && ./configure --with-luajit && make && make install)
run echo "uwsgi_param   UWSGI_SCHEME     \$scheme;" >> /usr/local/openresty/nginx/uwsgi_params
run mkdir /var/log/nginx
run easy_install pip
run pip install uwsgi
add run.sh /usr/local/bin/run
add . /app
run pip install -r /app/requirements.txt
env CACHE_REDIS_HOST 127.0.0.1
env CACHE_REDIS_PORT 6379
env CACHE_LRU_REDIS_HOST 127.0.0.1
env CACHE_LRU_REDIS_PORT 6379
expose 80
expose 443
cmd ["/usr/local/bin/run"]
