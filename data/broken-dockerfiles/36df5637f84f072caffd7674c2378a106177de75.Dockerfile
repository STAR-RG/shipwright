FROM python:3

ARG RUN_AS

ENV LC_ALL=C.UTF-8 \
	LANG=C.UTF-8 \
	LANGUAGE=C.UTF-8 \
	PYTHONUNBUFFERED=1

ADD . /opt/shakal/

RUN apt-get -y update && \
	apt-get install -y gettext uwsgi-plugin-python3 uwsgi && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	cd /opt/shakal && \
	pip3 install --no-cache-dir -r requirements.dev.txt --src /usr/local/src && \
	export USER_ID=`echo $RUN_AS|cut -d ":" -f 1` && \
	export GROUP_ID=`echo $RUN_AS|cut -d ":" -f 2` && \
	groupadd -g ${GROUP_ID} shakal && \
	useradd -l -u ${USER_ID} -g shakal -d /opt/shakal shakal && \
	chown -R ${USER_ID}:${GROUP_ID} /opt/shakal

USER shakal
WORKDIR /opt/shakal
EXPOSE 8000

CMD "/bin/bash"
