FROM resin/raspberrypi-node:5.3.0-slim-20160114

RUN apt-get update && apt-get install -y --no-install-recommends \
		python \
		build-essential \
		mongodb \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /datadb

COPY package.json .

RUN npm install

COPY . .

EXPOSE 8080

CMD bash start.sh
