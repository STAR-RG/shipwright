# Ubuntu 13.04 to get Python 2.7.4
FROM stackbrew/ubuntu:raring

RUN apt-get -q update
RUN apt-get install -y python python-pip python-dev libxml2-dev libxslt-dev libpq-dev python-psycopg2 git

# Install Ruby + Foreman
RUN apt-get install -y ruby rubygems
RUN gem install foreman

ADD requirements.txt /code/requirements.txt
RUN pip install -r /code/requirements.txt

# Remove unnecessary packages
RUN apt-get autoremove -y

ADD .env /code/.env
WORKDIR /code/
EXPOSE 8000

CMD foreman run python server/manage.py runserver 0.0.0.0:8000