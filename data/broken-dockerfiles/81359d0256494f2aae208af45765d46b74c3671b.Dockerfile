FROM python:2.7

RUN pip install dumb-init

RUN mkdir /opt/openteamstatus
WORKDIR /opt/openteamstatus

COPY requirements.txt /opt/openteamstatus/requirements.txt
RUN pip install -r requirements.txt

ADD openteamstatus /opt/openteamstatus/openteamstatus
ADD core /opt/openteamstatus/core
ADD checkins /opt/openteamstatus/checkins
ADD magiclink /opt/openteamstatus/magiclink
ADD manage.py /opt/openteamstatus/manage.py
ADD supervisord.conf /opt/openteamstatus/supervisord.conf

RUN ./manage.py collectstatic --no-input

ENV PYTHONPATH=/opt/openteamstatus/
ENV DEBUG=false
ENV C_FORCE_ROOT=true

ENTRYPOINT ["dumb-init", "--"]
CMD ["supervisord", "-c", "supervisord.conf"]

