FROM python:3.7-slim
ENV PYTHONUNBUFFERED 1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    zlib1g-dev \
    libjpeg-dev \
    binutils \
    git \
    libproj-dev \
    wget \
    gdal-bin && rm -rf /var/lib/apt/lists/*

#RUN mkdir /src
WORKDIR /src
ADD requirements.txt /src/
ADD requirements /src/requirements
RUN pip install -r requirements.txt
# Habilitar los siguientes para facilitar el debugging.
#RUN pip install django-debug-toolbar
#RUN pip install Werkzeug
ADD . /src/

# Dejamos un archivo version.txt con el timestamp de cuándo fue generada esa versión
RUN mkdir /tmp/version
RUN date +"%Y%m%d%H%M" > /tmp/version/version.txt

EXPOSE 8000
CMD ["bash", "entrypoint.sh"]
