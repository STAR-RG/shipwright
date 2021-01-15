#
# First Flask App Dockerfile
#
#

# Pull base image.
FROM centos:7.0.1406

# Build commands
RUN yum swap -y fakesystemd systemd && \
    yum install -y systemd-devel
RUN yum install -y python-setuptools mysql-connector-python mysql-devel gcc python-devel git
RUN easy_install pip
RUN mkdir /opt/flask_blog
WORKDIR /opt/flask_blog
ADD requirements.txt /opt/flask_blog/
RUN pip install -r requirements.txt
ADD . /opt/flask_blog

# Define working directory.
WORKDIR /opt/flask_blog

# Define default command.
# CMD ["python", "manage.py", "runserver"]
