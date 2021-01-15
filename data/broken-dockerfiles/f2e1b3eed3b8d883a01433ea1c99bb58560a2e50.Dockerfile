FROM continuumio/anaconda

RUN apt-get install -y gcc git python-dev unzip
RUN yes | pip install wordcloud
RUN conda install -y jupyter pandas scikit-learn nltk matplotlib
RUN python -m nltk.downloader book

RUN mkdir /notebooks
WORKDIR /notebooks
COPY . .

CMD sh run_notebook_server.sh
