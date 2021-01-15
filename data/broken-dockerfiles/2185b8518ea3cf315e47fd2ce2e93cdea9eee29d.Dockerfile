FROM balenalib/%%BALENA_MACHINE_NAME%%-python:3-stretch-run

# Install Dropbear.
RUN install_packages dropbear

# Install Flask
COPY ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

COPY . /usr/src/app
WORKDIR /usr/src/app

CMD ["bash", "start.sh"]
