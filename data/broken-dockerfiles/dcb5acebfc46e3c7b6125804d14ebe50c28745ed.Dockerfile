FROM gcr.io/google_containers/fluentd-elasticsearch
#already prebuild image by k8s team

ENV KUBE_GEN_VERSION 0.1.3

# Copy over the template
COPY td-agent.conf /etc/td-agent/td-agent.conf

ADD https://github.com/kylemcc/kube-gen/releases/download/0.1.1/kube-gen-linux-amd64-0.1.3.tar.gz /tmp
RUN tar -C /usr/local/bin -xvzf /tmp/kube-gen-linux-amd64-0.1.3.tar.gz
RUN chmod +x /usr/local/bin/kube-gen

ADD https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-amd64.tgz /tmp
RUN tar -C /usr/local/bin -xzvf /tmp/forego-stable-linux-amd64.tgz 
RUN chmod +x /usr/local/bin/forego



# TODO 
ENTRYPOINT ["td-agent"]