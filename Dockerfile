FROM python:3-stretch

RUN pip3 install --upgrade pip && pip3 install hdbscan sentence-transformers tqdm

RUN apt-get update && apt-get install -y bc


