# yubikey-validation-server
# Author : Maxime VISONNEAU - @mvisonneau
#
# VERSION 0.1
# 
# Prereq :  apt-get install rng-tools && rngd -r /dev/urandom
# BUILD : 	docker build -t <username>/yubikey-server:0.1 .
# RUN :		docker run --name yubikey-server -d -p 8000:80 <yourname>/yubikey-server:0.1
# 	

FROM ubuntu:14.04
MAINTAINER Maxime VISONNEAU <maxime.visonneau@gmail.com>

## Custom variables
ENV KEYS_AMOUNT = 10			# Total of keys that will be generated = Amount of Yubikey you want to manage with this KSM
ENV DB_PASSWORD = unsecured		# Database password

# Installation & Configuration

RUN DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y --force-yes debconf software-properties-common supervisor
RUN mkdir -p /root /var/lock/apache2 /var/run/apache2 /var/log/supervisor
ADD ./conf/ /root/
ADD ./conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN debconf-set-selections /root/yubi.seed
RUN add-apt-repository ppa:yubico/stable
RUN apt-get update
RUN echo 'exit 0' > /usr/sbin/policy-rc.d 
RUN apt-get install -y --force-yes yubikey-ksm yubikey-val
RUN gpg --no-tty --batch --trust-model always --gen-key /root/gpg.conf
RUN gpg --no-tty --import default.sec
RUN ykksm-gen-keys --urandom 1 $KEYS_AMOUNT > /root/keys.txt
RUN gpg --no-tty --trust-model always -a -s --encrypt -r `gpg --no-tty --list-keys | head -n 3 | tail -1 | awk '{print $2}' | cut -d '/' -f2` < /root/keys.txt > /root/encrypted_keys.txt
RUN /etc/init.d/mysql start && ykksm-import < /root/encrypted_keys.txt
RUN /etc/init.d/mysql start && \
	echo "######### KEYS ###########" && \
	echo "---" && \
	for i in `grep -v ^# /root/keys.txt`; do echo "key`echo $i | cut -d',' -f1`:"; echo "  public_id: `echo $i | cut -d',' -f2`"; echo "  private_id: `echo $i | cut -d',' -f3`";  echo "  secret_key: `echo $i | cut -d',' -f4`"; done; \
	rm -f /root/keys.txt && \
	echo "######## CLIENT ##########" && \
	echo "---\nclient:" && \
	echo "  id:  `ykval-export-clients | cut -d',' -f1`" && \
	echo "  key: `ykval-export-clients | cut -d',' -f4`"

# Expose and Startup
EXPOSE 80
ENTRYPOINT ["/usr/bin/supervisord"]