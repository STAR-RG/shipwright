FROM zuazo/chef-local:debian-7

COPY . /tmp/postfixadmin
RUN berks vendor -b /tmp/postfixadmin/Berksfile $COOKBOOK_PATH
RUN chef-client -r "recipe[apt],recipe[postfixadmin]"

CMD ["apache2", "-D", "FOREGROUND"]
