FROM ubuntu
EXPOSE 80:8080
RUN apt-get install -y ca-certificates
ADD subgun /bin/
CMD /bin/subgun
