FROM tiangolo/uwsgi-nginx-flask:flask

COPY * /app

RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
RUN apt-get update && apt-get install -y ruby-full haskell-platform shellcheck nodejs build-essential nodejs-legacy

RUN pip install -r /app/requirements.txt
