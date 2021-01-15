FROM granoproject/base:latest

# Node dependencies
RUN npm --quiet --silent install -g bower uglify-js less

COPY . /siyazana
WORKDIR /siyazana
RUN python setup.py -qq install

RUN bower install --quiet --allow-root

CMD gunicorn -w 3 -t 1800 connectedafrica.manage:app
