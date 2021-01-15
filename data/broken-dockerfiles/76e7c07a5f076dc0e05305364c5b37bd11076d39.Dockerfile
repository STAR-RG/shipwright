FROM python:3.5
MAINTAINER Johannes Gontrum <https://github.com/jgontrum>

ENV CHECK_URL "https://www.google.com"
ENV CHECK_FOR "initHistory"
ENV PROXY_TIMEOUT "10.0"
ENV PROXY_FILE "/scripts/files/proxies.txt"

RUN mkdir -p /scripts
RUN mkdir -p /scripts/files

COPY gimmeproxy.py /scripts/gimmeproxy.py
COPY parse_proxy_list.py /scripts/parse_proxy_list.py
COPY haproxy.cfg /scripts/haproxy.cfg
COPY requirements.txt /scripts/requirements.txt
COPY run.sh /scripts/run.sh
COPY proxies.txt /scripts/files/proxies.txt

RUN echo deb http://httpredir.debian.org/debian jessie-backports main | sed 's/\(.*\)-sloppy \(.*\)/&@\1 \2/' | tr @ '\n' | tee /etc/apt/sources.list.d/backports.list

RUN apt-get update
RUN apt-get install -y --force-yes iptables zlib1g zlib1g-dev haproxy -t jessie-backports --fix-missing
RUN apt-get clean

RUN pip install -r /scripts/requirements.txt

RUN chmod -R 777 /scripts
RUN chmod -R 777 /etc/haproxy

CMD ["/scripts/run.sh"]
EXPOSE 5566
