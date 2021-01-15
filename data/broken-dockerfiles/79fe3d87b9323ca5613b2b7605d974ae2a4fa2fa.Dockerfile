FROM jboss/base-jdk:8

ENV DOWNLOAD_URL=http://racha-cuca.devnull.tools/install/redhat/fuse/jboss-fuse-karaf-6.3.0.redhat-224.zip
ENV FUSE_HOME=/opt/jboss/fuse
ENV FUSE_USER=admin
ENV FUSE_PASSWORD=admin
ENV VERSION="0.11.0-SNAPSHOT"
ENV DEBUG=""

USER root
COPY .docker/scripts/install.sh /install.sh
RUN /install.sh && rm /install.sh

COPY .docker/cfg/* $FUSE_HOME/etc/
COPY .docker/scripts/entrypoint.sh /opt/jboss/entrypoint.sh

COPY target/lib/trugger-6.2.0.jar \
  target/lib/jsoup-1.10.2.jar \
  target/lib/mongo-java-driver-3.0.4.jar \
  channels/boteco-channel-email/target/boteco-channel-email-${VERSION}.jar \
  channels/boteco-channel-irc/target/boteco-channel-irc-${VERSION}.jar \
  channels/boteco-channel-pushover/target/boteco-channel-pushover-${VERSION}.jar \
  channels/boteco-channel-telegram/target/boteco-channel-telegram-${VERSION}.jar \
  channels/boteco-channel-user/target/boteco-channel-user-${VERSION}.jar \
  main/boteco/target/boteco-${VERSION}.jar \
  main/boteco-amq-client/target/boteco-amq-client-${VERSION}.jar \
  main/boteco-event-bus/target/boteco-event-bus-${VERSION}.jar \
  main/boteco-event-processor/target/boteco-event-processor-${VERSION}.jar \
  main/boteco-message-formatter/target/boteco-message-formatter-${VERSION}.jar \
  main/boteco-message-processor/target/boteco-message-processor-${VERSION}.jar \
  main/boteco-rest-api/target/boteco-rest-api-${VERSION}.jar \
  main/boteco-rest-client/target/boteco-rest-client-${VERSION}.jar \
  persistence/boteco-persistence-irc/target/boteco-persistence-irc-${VERSION}.jar \
  persistence/boteco-persistence-karma/target/boteco-persistence-karma-${VERSION}.jar \
  persistence/boteco-persistence-manager/target/boteco-persistence-manager-${VERSION}.jar \
  persistence/boteco-persistence-mongodb/target/boteco-persistence-mongodb-${VERSION}.jar \
  persistence/boteco-persistence-request/target/boteco-persistence-request-${VERSION}.jar \
  persistence/boteco-persistence-subscription/target/boteco-persistence-subscription-${VERSION}.jar \
  persistence/boteco-persistence-user/target/boteco-persistence-user-${VERSION}.jar \
  plugins/boteco-plugin-definitions/target/boteco-plugin-definitions-${VERSION}.jar \
  plugins/boteco-plugin-diceroll/target/boteco-plugin-diceroll-${VERSION}.jar \
  plugins/boteco-plugin-facts/target/boteco-plugin-facts-${VERSION}.jar \
  plugins/boteco-plugin-help/target/boteco-plugin-help-${VERSION}.jar \
  plugins/boteco-plugin-irc/target/boteco-plugin-irc-${VERSION}.jar \
  plugins/boteco-plugin-karma/target/boteco-plugin-karma-${VERSION}.jar \
  plugins/boteco-plugin-manager/target/boteco-plugin-manager-${VERSION}.jar \
  plugins/boteco-plugin-ping/target/boteco-plugin-ping-${VERSION}.jar \
  plugins/boteco-plugin-providers/target/boteco-plugin-providers-${VERSION}.jar \
  plugins/boteco-plugin-redhat/target/boteco-plugin-redhat-${VERSION}.jar \
  plugins/boteco-plugin-request/target/boteco-plugin-request-${VERSION}.jar \
  plugins/boteco-plugin-subscription/target/boteco-plugin-subscription-${VERSION}.jar \
  plugins/boteco-plugin-user/target/boteco-plugin-user-${VERSION}.jar \
  plugins/boteco-plugin-weather/target/boteco-plugin-weather-${VERSION}.jar \
  plugins/boteco-plugin-xgh/target/boteco-plugin-xgh-${VERSION}.jar \
  plugins/boteco-plugin-timebomb/target/boteco-plugin-timebomb-${VERSION}.jar \
  providers/boteco-provider-chucknorris/target/boteco-provider-chucknorris-${VERSION}.jar \
  providers/boteco-provider-urbandictionary/target/boteco-provider-urbandictionary-${VERSION}.jar \
  providers/boteco-provider-yahooweather/target/boteco-provider-yahooweather-${VERSION}.jar $FUSE_HOME/deploy/

RUN chown -R jboss:jboss /opt/jboss
RUN chmod 777 -R /opt/jboss

USER jboss

VOLUME $FUSE_HOME/data
EXPOSE 8181 8101 5005

ENTRYPOINT ["/opt/jboss/entrypoint.sh"]
