FROM centos

MAINTAINER erickbrower

RUN yum install -y java-1.7.0-openjdk git unzip
RUN mkdir /opt/torquebox
RUN useradd torquebox -c"Torquebox system user" -M -ptorquebox
ADD http://torquebox.org/release/org/torquebox/torquebox-dist/3.0.0/torquebox-dist-3.0.0-bin.zip /tmp/tboxbin.zip
RUN unzip /tmp/tboxbin.zip -d /opt/torquebox
RUN ln -s /opt/torquebox/torquebox-3.0.0 /opt/torquebox/current
RUN chown -R torquebox:torquebox /opt/torquebox
RUN touch /etc/profile.d/torquebox.sh
RUN echo "export TORQUEBOX_HOME=/opt/torquebox/current" >> /etc/profile.d/torquebox.sh
RUN echo "export JBOSS_HOME=\$TORQUEBOX_HOME/jboss" >> /etc/profile.d/torquebox.sh
RUN echo "export JRUBY_HOME=\$TORQUEBOX_HOME/jruby" >> /etc/profile.d/torquebox.sh
RUN echo "PATH=\$JBOSS_HOME/bin:\$JRUBY_HOME/bin:\$PATH" >> /etc/profile.d/torquebox.sh

ENV TORQUEBOX_HOME /opt/torquebox/current
ENV JBOSS_HOME /opt/torquebox/current/jboss
ENV JRUBY_HOME /opt/torquebox/current/jruby
ENV PATH $JBOSS_HOME/bin:$JRUBY_HOME/bin:$PATH

RUN cp /opt/torquebox/current/jboss/bin/init.d/jboss-as-standalone.sh /etc/init.d/jboss-as-standalone
RUN mkdir /etc/jboss-as && touch /etc/jboss-as/jboss-as.conf
RUN echo "JBOSS_USER=torquebox" >> /etc/jboss-as/jboss-as.conf
RUN echo "JBOSS_HOME=/opt/torquebox/current/jboss" >> /etc/jboss-as/jboss-as.conf
RUN echo "JBOSS_PIDFILE=/var/run/torquebox/torquebox.pid" >> /etc/jboss-as/jboss-as.conf
RUN echo "JBOSS_CONSOLE_LOG=/var/log/torquebox/console.log" >> /etc/jboss-as/jboss-as.conf
RUN echo "JBOSS_CONFIG=standalone-ha.xml" >> /etc/jboss-as/jboss-as.conf
RUN chkconfig --add jboss-as-standalone

EXPOSE 6666 8080 8443 5445 8675

ENTRYPOINT ['/opt/torquebox/current/jruby/bin/torquebox']
