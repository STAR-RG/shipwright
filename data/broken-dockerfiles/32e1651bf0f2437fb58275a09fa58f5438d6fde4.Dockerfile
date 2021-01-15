FROM rafkhan/rangle-node:14.04-4.3.0

# setup the application home
RUN mkdir /home/app
COPY . /home/app/

# setup user
USER root
RUN mkdir /home/swuser
RUN groupadd -r swuser -g 433 && \
useradd -u 431 -r -g swuser -d /home/swuser -s /sbin/nologin \
-c "Docker image user" swuser && \
chown -R swuser:swuser /home/swuser

# own the project folder
RUN sudo chown -R swuser:swuser /home/app

# install the application
USER swuser
RUN cd /home/app/; npm install;

## Expose the ports
USER root
EXPOSE 9090
EXPOSE 3000

# Use unprivileged user
USER swuser
CMD ["/home/app/.clusternator/serve.sh"]
