FROM helder/nginx-extras

RUN apt-get update && \
    apt-get install curl --no-install-recommends -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -SL 'https://bootstrap.pypa.io/get-pip.py' | python3

RUN pip install --no-cache-dir Jinja2

COPY etc /etc/nginx_extras
RUN rm -rf /etc/nginx && \
    mv /etc/nginx_extras /etc/nginx && \
    mkdir -p /etc/nginx/sites-enabled

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
