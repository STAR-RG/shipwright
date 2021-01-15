FROM ubuntu:16.04
RUN apt-get update && apt-get -y install git unzip ruby ruby-dev curl gcc make
RUN curl -fssl "https://releases.hashicorp.com/terraform/0.9.0/terraform_0.9.0_linux_amd64.zip" -o /home/terraform.zip
RUN unzip -o -q /home/terraform.zip -d /home/terraform && mv /home/terraform/terraform /usr/local/bin/terraform
RUN gem install travis -v 1.8.8 --no-rdoc --no-ri
RUN mkdir /home/workspace && cd /home/workspace
CMD /bin/bash
