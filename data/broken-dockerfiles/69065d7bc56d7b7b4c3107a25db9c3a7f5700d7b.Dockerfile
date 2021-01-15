FROM python:2.7

RUN mkdir -p /app
COPY . /app/tuxedo/tuxedo
COPY version.json /app/version.json

WORKDIR /app/tuxedo/tuxedo

RUN \
    apt-get update && \
    apt-get install -y -qq python-mysqldb && \
    pip install -r requirements.txt && \
    pip install gunicorn==19.6.0 && \
    cp wsgi/tuxedo.wsgi wsgirunner.py

EXPOSE 8000

ENV PYTHONPATH="/app/tuxedo:/app/tuxedo/tuxedo/vendor/lib/python:/app/tuxedo/tuxedo/vendor/src"

CMD ["/app/tuxedo/tuxedo/bin/start", "-b", "127.0.0.1:8000", "-w", "24", "wsgirunner"]
