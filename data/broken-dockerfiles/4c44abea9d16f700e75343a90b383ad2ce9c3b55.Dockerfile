FROM java:8

RUN apt-get update

RUN apt-get install -y maven

RUN ls -l

WORKDIR /code

ADD pom.xml /code/pom.xml

ADD src /code/src

CMD ["mvn", "test"]