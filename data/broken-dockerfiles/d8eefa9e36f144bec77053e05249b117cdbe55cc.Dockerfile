from ubuntu:12.10
maintainer Nick Stinemates

run apt-get update

# install node
run apt-get install -y wget curl
run wget -O - http://nodejs.org/dist/v0.10.20/node-v0.10.20-linux-x64.tar.gz | tar -C /usr/local/ --strip-components=1 -zxv

#install ruby
run apt-get install -y ruby1.9.3

#install dependencies
run gem install sass
run gem install bourbon

add . /ghost

# make sure the process listens globally
run cp /ghost/config.example.js /ghost/config.js
run sed -i 's/127.0.0.1/0.0.0.0/' /ghost/config.js

run cd /ghost && npm install -g grunt-cli
run cd /ghost && npm install .
run cd /ghost && npm install -g grunt-contrib-sass

# currently a warning for invalid chars, patching to fix

run cd /ghost && sed -i '1s/^/@charset "UTF-8";\n/' ./core/client/assets/sass/layouts/errors.scss
run cd /ghost && grunt init --force

volume /ghost/content/data

workdir /ghost
expose 2368

cmd ["npm", "start"]

