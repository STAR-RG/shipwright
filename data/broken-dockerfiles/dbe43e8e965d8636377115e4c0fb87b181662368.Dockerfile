FROM ubuntu:18.04
MAINTAINER Joe Jasinski

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ansible python-apt

ADD . /srv/ansible/

RUN ansible-playbook -vvvv --inventory-file=/srv/ansible/ansible/inventory.ini \
   /srv/ansible/ansible/playbook-all.yml -c local

CMD ["/srv/ansible/docker-utils/run.sh"]
EXPOSE 80 443
