FROM python:3.6.7-alpine3.6
ADD . /opt/app
WORKDIR /opt/app
RUN  apk --no-cache --virtual build  add libffi-dev openssl-dev build-base &&pip install -r *.txt &&apk del build && rm -rf ~/.cache/pip
CMD ["python","SSF.py"]
