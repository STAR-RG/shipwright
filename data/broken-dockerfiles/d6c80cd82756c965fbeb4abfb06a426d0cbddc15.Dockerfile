FROM openshift/origin-ansible:v3.10

WORKDIR /demos

USER root

ADD helpers/bin/fix-permissions /usr/bin/fix-permissions
ADD helpers/bin/run-playbook /usr/bin/run-playbook
ADD playbooks /demos/playbooks
ADD ansible.cfg /demos

RUN yum -y install nss_wrapper unzip && \
    yum clean all && \
    localedef -f UTF-8 -i en_US en_US.UTF-8 && \
    /usr/bin/fix-permissions /demos

USER 1001

ENTRYPOINT ["run-playbook"]