FROM python:3.6.6-alpine3.6
LABEL maintainer="Senan Kelly <senan@senan.xyz>"
WORKDIR /app
COPY requirements.txt steely/ ./
RUN \
    apk add --no-cache \
        python3-dev \
        build-base \
    && \
    pip install \
        -r requirements.txt
VOLUME /root/.local/share/steely/
VOLUME /root/.config/steely/
CMD [ "/usr/local/bin/python", "/app/steely.py" ]
