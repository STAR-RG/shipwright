FROM binhex/arch-int-openvpn:latest
MAINTAINER binhex

# additional files
##################

# add supervisor conf file for app
ADD build/*.conf /etc/supervisor/conf.d/

# add bash scripts to install app
ADD build/root/*.sh /root/

# add run bash scripts
ADD run/root/*.sh /root/

# add run bash scripts
ADD run/nobody/*.sh /home/nobody/

# add pre-configured config files for nobody
ADD config/nobody/ /home/nobody/

# install app
#############

# make executable and run bash scripts to install app
RUN chmod +x /root/*.sh /home/nobody/*.sh && \
	/bin/bash /root/install.sh

# docker settings
#################

# add pyrocore symlinks to path - symlinks from /opt/pyrocore to /home/nobody/bin
ENV PATH="${PATH}:/home/nobody/bin"

# map /config to host defined config path (used to store configuration from app)
VOLUME /config

# map /data to host defined data path (used to store data from app)
VOLUME /data

# expose port for scgi
EXPOSE 5000

# expose port for rutorrent http
EXPOSE 9080

# expose port for rutorrent https
EXPOSE 9443

# expose port for privoxy
EXPOSE 8118

# expose port for incoming connections (used only if vpn disabled)
EXPOSE 49160

# expose port for dht udp (used only if vpn disabled)
EXPOSE 49170

# set permissions
#################

# run script to set uid, gid and permissions
CMD ["/bin/bash", "/usr/local/bin/init.sh"]