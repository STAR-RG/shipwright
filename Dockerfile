FROM python:3-stretch

RUN pip3 install --upgrade pip && pip3 install \
  hdbscan sentence-transformers tqdm nltk google termcolor

RUN apt-get update && apt-get install -y bc


