FROM danielquinn/django:debian

COPY /requirements.txt /app/requirements.txt

# Install build dependencies
RUN apt-get update \
  && apt-get install -y gcc libffi-dev \
  && pip install -r /app/requirements.txt \
  && apt-get remove -y gcc \
  && apt-get clean

EXPOSE 8000

ENTRYPOINT /app/docker.entrypoint
