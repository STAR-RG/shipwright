FROM python:2.7

# Assumes volume is being mounted at /srv/wikimetrics and
# config mounted at /srv/wikimetrics/config

# Setup a temp directory
ENV temp_dir /tmp/wikimetrics
RUN mkdir $temp_dir
WORKDIR /tmp/wikimetrics

# Install app requirements
ADD ./requirements.txt $temp_dir/requirements.txt
RUN pip install -r requirements.txt
RUN pip install uwsgi

# Intall test requirements
ADD ./test-requirements.txt $temp_dir/test-requirements.txt
RUN pip install -r test-requirements.txt

# Install the wikimetrics app
ADD . $temp_dir
RUN python setup.py install

# Let www-data own our temporary directory
RUN chown -R www-data $temp_dir

# Reset the working directory
WORKDIR /srv/wikimetrics
