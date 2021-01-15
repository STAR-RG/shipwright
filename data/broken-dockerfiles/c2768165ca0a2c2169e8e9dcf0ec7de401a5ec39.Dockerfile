FROM python:2.7
ADD . scikit-learn
WORKDIR scikit-learn/doc
RUN pip install -r requirements.txt
RUN make html-zh
WORKDIR _build/html-zh
CMD python -m SimpleHTTPServer
