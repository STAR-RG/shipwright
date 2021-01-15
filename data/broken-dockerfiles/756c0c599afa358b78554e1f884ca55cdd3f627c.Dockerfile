#
# Reverse proxy for kubernetes
#
FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

# Prepare requirements
RUN apt-get update -qy && \
    apt-get install --no-install-recommends -qy software-properties-common

# Install Nginx.
RUN add-apt-repository -y ppa:nginx/stable && \
    apt-get update -q && \
    apt-get install --no-install-recommends -qy nginx && \
    chown -R www-data:www-data /var/lib/nginx && \
    rm -f /etc/nginx/sites-available/default

# Install Python 3.5 and pip3
RUN add-apt-repository -y ppa:fkrull/deadsnakes && \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy python3.5 curl && \
    curl -O https://bootstrap.pypa.io/get-pip.py && \
    python3.5 get-pip.py && \
    rm get-pip.py

# Add the boot script
ADD src/boot.sh /opt/boot.sh
RUN chmod +x /opt/boot.sh

# Add the generator and the template
ADD src/requirements.txt /opt/requirements.txt
ADD src/generator.py /opt/generator.py
ADD src/templates /opt/templates

RUN pip3 install -r /opt/requirements.txt

# Nginx ports
EXPOSE 80 443

# Set the boot script
CMD /opt/boot.sh
