FROM python:2.7

WORKDIR /usr/src/app

RUN pip install errbot crontab
RUN mkdir /var/lib/err

ADD samples/config.py ./
ADD samples/demo.plug ./
ADD samples/demo.py ./
# RUN pip install errcron -i https://testpypi.python.org/pypi
ADD errcron/ ./errcron

CMD ["errbot", "-T"]
