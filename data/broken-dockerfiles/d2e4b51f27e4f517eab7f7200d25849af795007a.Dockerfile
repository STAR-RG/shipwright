# To DEBUG, do:
# docker build . -t redpipe && docker run -it redpipe /bin/bash

# To RUN tox, do:
# docker build . -t redpipe && docker run redpipe

# To BENCHMARK, do:
# docker build . -t redpipe && docker run -it redpipe /bin/bash
# toxiproxy-server &
# toxiproxy-cli create redis -l localhost:26379 -u localhost:6379
# toxiproxy-cli toxic add redis -t latency -a latency=1
# py.test ./bench.py --port 26379


FROM themattrix/tox-base

# Install toxiproxy
RUN wget -O toxiproxy.deb https://github.com/Shopify/toxiproxy/releases/download/v2.1.0/toxiproxy_2.1.0_amd64.deb
RUN dpkg -i toxiproxy.deb
RUN rm toxiproxy.deb

COPY requirements.txt /app/
COPY dev-requirements.txt /app/
RUN pyenv global 3.5.2
RUN pip install -r dev-requirements.txt
COPY tox.ini /app/
COPY setup.py /app/
COPY README.rst /app/
COPY MANIFEST.in /app/
COPY README.rst /app/
COPY LICENSE /app/
COPY conftest.py /app/
COPY test.py /app/
COPY docs /app/docs/
COPY redpipe /app/redpipe/
COPY bench.py /app/
