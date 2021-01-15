FROM prologic/python-runtime:2.7

ENV DOMAIN=mydomain.com

ENTRYPOINT ["/entrypoint.sh"]
CMD ["up"]

RUN pip install docker-compose j2cli

COPY entrypoint.sh /entrypoint.sh
COPY docker-compose.yml.j2 /docker-compose.yml.j2
