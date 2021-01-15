FROM crosbymichael/python

RUN apt-get update && apt-get install -y \
    postgresql-client-common \
    libpq-dev \
    mysql-client \
    libmysqlclient-dev

RUN pip install MySQL-python psycopg2 sentry redis

EXPOSE 9000
ONBUILD ADD sentry.conf.py /sentry.conf.py

ENTRYPOINT ["/usr/local/bin/sentry", "--config=/sentry.conf.py"]
CMD ["start"]
