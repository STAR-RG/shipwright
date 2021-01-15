FROM python:3.6.6-alpine3.8
LABEL maintainer="dev@smarttrade.co.jp"

RUN apk update && \
    apk upgrade && \
    apk add --no-cache --virtual .build-deps make automake gcc g++ subversion python3-dev freetype-dev libpng-dev openblas-dev libxml2-dev libxslt-dev

RUN pip install matplotlib jupyterlab jupyter_contrib_nbextensions 
RUN jupyter contrib nbextension install
RUN pip install pyfolio
RUN pip install quantx-sdk
#RUN apk del .build-deps

CMD [ "jupyter-lab",  \
        "--allow-root", \
        "--ip=0.0.0.0", \
        "--port=8888"]
