FROM floydhub/python-base:latest-gpu-py3

MAINTAINER "Antonio De Marinis" <demarinis@eea.europa.eu>

ADD ./src/eea.corpus/requirements.txt /src/eea.corpus/requirements.txt

WORKDIR /src/eea.corpus

RUN pip --no-cache-dir install -U -r requirements.txt

RUN python -m spacy download en

# convert phrasemachine to python3 code
RUN cd /usr/local/lib/python3.5/site-packages/phrasemachine \
        && 2to3 -w *.py

ADD ./src /src

WORKDIR /src/eea.corpus

RUN pip install -e ".[testing]"

CMD pserve /src/eea.corpus/development.ini

EXPOSE 6543
