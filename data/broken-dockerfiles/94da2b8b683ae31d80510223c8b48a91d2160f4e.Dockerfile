FROM ubuntu:15.10
RUN apt-get update
RUN apt-get install -y ca-certificates wget libpq5 libgmp10 netbase
ADD hs-certificate-transparency .
RUN chmod u+x hs-certificate-transparency
CMD ["./hs-certificate-transparency"]
