FROM continuumio/miniconda
RUN conda config --add channels https://conda.binstar.org/travis \
    && conda config --add channels https://conda.binstar.org/dan_blanchard \
    && conda config --set ssl_verify false \
    && conda update --yes conda
RUN pip install --upgrade pip
ADD requirements.txt /app/requirements.txt
RUN cat /app/requirements.txt | grep 'scipy\|numpy\|cchardet\|PyStemmer\|^lxml\|scikit-learn' > /app/conda.txt
RUN conda install --yes --file /app/conda.txt
RUN pip install -r /app/requirements.txt
ADD SentiWS_v1.8c /app/SentiWS_v1.8c
ADD stopwords.txt /app/stopwords.txt
ADD supervisord.conf /app/supervisord.conf
ADD api.py /app/api.py
ADD jobs.py /app/jobs.py
ADD newsreader.py /app/newsreader.py
ADD downloader.py /app/downloader.py
ADD classifier.py /app/classifier.py
ADD vectorizer.py /app/vectorizer.py
ADD abgeordnete.txt /app/abgeordnete.txt
ADD model /app/model
ADD web/build /app/web/build

WORKDIR /app
EXPOSE 5000
CMD supervisord -c /app/supervisord.conf
