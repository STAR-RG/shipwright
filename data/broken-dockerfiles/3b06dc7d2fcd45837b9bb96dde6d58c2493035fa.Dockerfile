FROM debian

RUN apt-get update && apt-get install -y python-pip python-dev libssl-dev mongodb-server build-essential libffi-dev 

COPY requirements.txt /

RUN pip install -r /requirements.txt

COPY app/api.py /usr/local/bin/api.py

RUN chmod 740 /usr/local/bin/api.py

ENTRYPOINT /usr/local/bin/api.py

EXPOSE 5000
