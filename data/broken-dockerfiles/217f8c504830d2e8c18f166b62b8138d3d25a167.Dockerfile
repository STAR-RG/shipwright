FROM python:2.7
RUN apt-get -y update

ADD . /opt/pi_director/
WORKDIR /opt/pi_director
RUN pip install .
RUN find . -name \*.sqlite -delete
RUN initialize_pi_director_db production.ini
CMD gunicorn --paste /opt/pi_director/production.ini -b :6543 -w 4 -k eventlet
