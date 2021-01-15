FROM maven:3.3.3
MAINTAINER  feel  <fye@gizwits.com>
ADD  . /tmp/build/
RUN cd /tmp/build && mvn clean package  -Dmaven.test.skip=true \
         && mkdir -p /data \
        #拷贝编译结果到指定目录
        && mv oh-boot-framework/target/oh-stater-boot-1.0.jar  /app.jar \
        #清理编译痕迹
        && cd / && rm -rf /tmp/build
VOLUME /data
WORKDIR /data
EXPOSE 8080
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]