ARG IMAGE_VERSION=latest
FROM shridh0r/frappe:$IMAGE_VERSION
MAINTAINER Shridhar <shridharpatil2792@gmail.com>

COPY ./start_up.sh /home/frappe/start_up.sh
USER root
RUN chmod 777 /home/frappe/start_up.sh
ARG APP_PATH=https://github.com/frappe/erpnext.git
ARG BRANCH=master

USER frappe
WORKDIR /home/frappe/frappe-bench
RUN ../start_up.sh build
# CMD ["/home/frappe/frappe-bench/env/bin/gunicorn", "-b", "0.0.0.0:8000", "--workers", "28", "--threads", "4", "-t", "120", "frappe.app:application", "--preload"]
