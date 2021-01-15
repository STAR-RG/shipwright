FROM python:3

RUN pip install --upgrade pip

COPY ./requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt
COPY . /seo-demo

WORKDIR /seo-demo
ENV FLASK_APP=server

CMD gunicorn server:app --workers 8 --timeout 60 --bind 0.0.0.0:5000 --worker-class aiohttp.worker.GunicornWebWorker
