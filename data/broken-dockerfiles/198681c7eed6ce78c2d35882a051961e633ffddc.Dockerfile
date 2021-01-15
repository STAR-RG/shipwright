# Basic docker image for PokemonGo-Map
# Usage:
#   docker build -t pokemongo-map .
#   docker run -d -P pokemongo-map -a ptc -u YOURUSERNAME -p YOURPASSWORD -l "Seattle, WA" -st 10 --google-maps-key CHECKTHEWIKI
#   docker run -P pokemongo-map --help

FROM python:2.7-alpine

# Default port the webserver runs on
EXPOSE 5000

# Working directory for the application
WORKDIR /app

# Set Entrypoint with hard-coded options
ENTRYPOINT ["python", "./runserver.py"]

# add certificates to talk to the internets
RUN apk add --no-cache ca-certificates

# Copy Python requirements so we only rebuild deps if they have changed
COPY requirements.txt /app/

# Install all prerequisites (build base used for gcc of some python modules)
RUN apk add --no-cache build-base git curl-dev openssl-dev \
 && PYCURL_SSL_LIBRARY=openssl pip install --no-cache-dir -r requirements.txt \
 && apk del build-base

# Add the rest of the app code
COPY . /app
