FROM balenalib/%%BALENA_MACHINE_NAME%%-debian:latest

WORKDIR /usr/src/app

COPY . ./

CMD ["bash", "start.sh"]

