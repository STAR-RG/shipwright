FROM 11.4.76.193/redis/openjdk:8
MAINTAINER wuzuzuquan 

ADD restapi-1.0.0.jar server.jar


EXPOSE 8080
CMD ["java","-jar","-Xms4G","-Xmx4G","-Xss256k","-Xmn1500m","-XX:-UseGCOverheadLimit","-XX:+HeapDumpOnOutOfMemoryError","/server.jar"]