FROM tutum/lamp:latest
RUN rm -fr /app && git clone https://github.com/shzshi/TestEnvironmentBooking.git /app
#ADD /app/init_db.sh /tmp/init_db.sh
RUN chmod a+x /app/init_db.sh
RUN /app/init_db.sh
EXPOSE 80 3306
CMD ["/run.sh"]
