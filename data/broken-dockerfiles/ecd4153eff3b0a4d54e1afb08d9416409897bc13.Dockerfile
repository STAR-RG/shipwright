FROM python:3.5.1-alpine

WORKDIR /usr/src/app

RUN apk --update add git

COPY requirements.txt /usr/src/app/
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

COPY . /usr/src/app

RUN adduser -u 9000 -D app
RUN chown -R app:app /usr/src/app
USER app

ENTRYPOINT ["/usr/local/bin/python", "-m", "codeclimate_test_reporter"]
