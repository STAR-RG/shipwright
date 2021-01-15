FROM java:8

MAINTAINER OpenSource Connections <ops@opensourceconnections.com>

EXPOSE 8080
EXPOSE 8081

RUN yum install -y openssl
RUN mkdir -p /srv/app/config

COPY target/grand-central-1.0-SNAPSHOT.jar /srv/app/
COPY config/configuration.yaml /srv/app/config/
COPY config/pod.yaml /srv/app/config/

RUN echo -n | openssl s_client -connect <KUBERNETES_MASTER_IP>:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /srv/app/config/k8s.pem
RUN keytool -importkeystore -srckeystore /usr/java/latest/lib/security/cacerts -destkeystore /srv/app/config/grandcentral.jks -srcstorepass changeit -deststorepass changeit
RUN echo "yes" | keytool -import -v -trustcacerts -alias local_k8s -file /srv/app/config/k8s.pem -keystore /srv/app/config/grandcentral.jks -keypass changeit -storepass changeit

CMD cd /srv/app && /usr/bin/java -jar /srv/app/grand-central-1.0-SNAPSHOT.jar server /srv/app/config/configuration.yaml
