FROM python:3-stretch

RUN pip3 install --upgrade pip && pip3 install \
  hdbscan sentence-transformers tqdm nltk google termcolor

RUN apt-get update && apt-get install -y bc xz-utils

COPY data/non-clustered-data/not-in-clusters.json.xz /not-in-clusters.json.xz

RUN xz -d /not-in-clusters.json.xz

RUN python3 -c 'import nltk ; nltk.download("stopwords") ; nltk.download("punkt")'
