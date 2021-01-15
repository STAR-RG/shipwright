FROM python:3.6
ENV PYTHONUNBUFFERED 1

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
&& apt-get update && apt-get install -y gettext postgresql-client nodejs \
&& wget https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -P /usr/bin \
&& chmod +x /usr/bin/wait-for-it.sh

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app
COPY requirements.txt package.json /usr/src/app/ 
RUN pip install -r requirements.txt
RUN npm install
COPY . /usr/src/app/
CMD /bin/sh -c "/usr/bin/wait-for-it.sh db:5432 -- ./app/manage.py migrate && ./app/manage.py loaddata tools/docker/user.json && ./app/manage.py runserver 0.0.0.0:8000"
