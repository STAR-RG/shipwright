FROM python:3.5-stretch
MAINTAINER Mario Vitale <mvitale1989@hotmail.com>

### Taiga configuration variables
ENV \
  TAIGA_HOSTNAME="localhost" \
  TAIGA_DB_NAME="" \
  TAIGA_DB_HOST="" \
  TAIGA_DB_USER="" \
  TAIGA_DB_PASSWORD="" \
  TAIGA_SSL="False" \
  TAIGA_SSL_BY_REVERSE_PROXY="False" \
  TAIGA_SECRET_KEY="!!!REPLACE-ME-j1598u1J^U*(y251u98u51u5981urf98u2o5uvoiiuzhlit3)!!!" \
  TAIGA_ENABLE_EMAIL="False" \
  TAIGA_EMAIL_FROM="" \
  TAIGA_EMAIL_USE_TLS="True" \
  TAIGA_EMAIL_HOST="" \
  TAIGA_EMAIL_PORT="" \
  TAIGA_EMAIL_USER="" \
  TAIGA_EMAIL_PASS="" \
  TAIGA_SKIP_DB_CHECK="" \
  TAIGA_DB_CHECK_ONLY="" \
  TAIGA_SLEEP="0" \
  TAIGA_EVENTS_ENABLE="False" \
  TAIGA_EVENTS_HOSTNAME="events" \
  RABBIT_HOST="rabbit:5672" \
  REDIS_HOST="redis:6379" \
  SAML_AUTH_ENABLE="False" \
  SAML_AUTH_JSON_CONFIG="" \
  SLACK_INTEGRATION_ENABLE="False" \
  LOGIN_FORM_TYPE="normal" \
  LDAP_AUTH_ENABLE="False" \
  LDAP_SERVER='ldap://ldap.example.com' \
  LDAP_PORT="389" \
  LDAP_START_TLS="False" \
  LDAP_BIND_DN='CN=SVC Account,OU=Service Accounts,OU=Servers,DC=example,DC=com' \
  LDAP_BIND_PASSWORD='<REPLACE_ME>' \
  LDAP_SEARCH_BASE='OU=DevTeam,DC=example,DC=net' \
  LDAP_SEARCH_FILTER_ADDITIONAL='(mail=*)' \
  LDAP_USERNAME_ATTRIBUTE='uid' \
  LDAP_EMAIL_ATTRIBUTE='mail' \
  LDAP_FULL_NAME_ATTRIBUTE='displayName'

 
### Setup system
COPY taiga-back /usr/src/taiga-back
COPY taiga-front-dist/ /usr/src/taiga-front-dist
COPY scripts /opt/taiga-bin
COPY conf /opt/taiga-conf
WORKDIR /usr/src/taiga-back
RUN chmod -R +x /opt/taiga-bin
RUN ["/opt/taiga-bin/docker-install.sh"]

### Container configuration
EXPOSE 80 443
VOLUME /usr/src/taiga-back/media
ENTRYPOINT ["/opt/taiga-bin/docker-entrypoint.sh"]
CMD ["python", "manage.py", "runserver", "127.0.0.1:8000"]
