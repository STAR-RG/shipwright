FROM analogic/poste.io
RUN touch /etc/services.d/clamd/down
RUN sed -i'' 's/^virus\/clamdscan/#virus\/clamdscan/' /etc/qpsmtpd/plugins
RUN echo 'protocols = $protocols' > /usr/share/dovecot/protocols.d/pop3d.protocol
