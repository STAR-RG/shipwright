FROM python:3.6

RUN git clone http://github.com/oroszgy/hungarian-text-mining-workshop

WORKDIR hungarian-text-mining-workshop

RUN  pip install --no-cache-dir -r requirements.txt \
  && rm -r /root/.cache

RUN python -m spacy download en \
  && rm -r /root/.cache

RUN pip install --no-cache-dir  https://github.com/oroszgy/spacy-hungarian-models/releases/download/hu_tagger_web_md-0.1.0/hu_tagger_web_md-0.1.0.tar.gz \
  && rm -r /root/.cache

RUN pip install --no-cache-dir https://github.com/oroszgy/hunlp/releases/download/0.2/hunlp-0.2.0.tar.gz \
  && rm -r /root/.cache

RUN pip install  --no-cache-dir cld2-cffi \
  && rm -r /root/.cache

WORKDIR /workshop 
EXPOSE 8888

