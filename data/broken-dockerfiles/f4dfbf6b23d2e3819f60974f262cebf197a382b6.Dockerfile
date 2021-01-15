FROM alpine
# load any public updates from Alpine packages
RUN apk update
# upgrade any existing packages that have been updated
RUN apk upgrade
# add/install python3 and related libraries
# https://pkgs.alpinelinux.org/package/edge/main/x86/python3
RUN apk add python3
# make a directory for our application
RUN mkdir -p /opt/app
# add our application files
ADD celery_conf.py /opt/app/celery_conf.py
ADD submit_tasks.py /opt/app/submit_tasks.py
# add the wrapper scripts for the primary process and probes
ADD run.sh /opt/app/run.sh
ADD celery_status.sh /opt/app/celery_status.sh
# move requirements file into the container
ADD requirements.txt /opt/app/requirements.txt
# install the library dependencies for this application
RUN pip3 install -r /opt/app/requirements.txt
# set the default directory for commands to be /opt/app
WORKDIR /opt/app
CMD ["/bin/sh", "-c","/opt/app/run.sh"]
