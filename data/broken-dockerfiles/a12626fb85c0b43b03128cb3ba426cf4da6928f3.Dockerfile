FROM alpine:latest

RUN apk add --update python py-pip redis ca-certificates

RUN pip install klassify
RUN python -c 'import nltk; nltk.download("stopwords")'

EXPOSE 8888
