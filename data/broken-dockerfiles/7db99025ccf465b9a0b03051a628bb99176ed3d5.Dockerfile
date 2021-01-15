FROM python:2.7-slim
ADD . /src
WORKDIR /src
RUN apt-get update && apt-get --yes --force-yes install build-essential python-dev libpng12-dev pkg-config libfreetype6-dev && pip install -r requirements.txt
CMD ["make", "run"]
