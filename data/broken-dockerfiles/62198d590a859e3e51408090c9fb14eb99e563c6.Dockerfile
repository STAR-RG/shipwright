#
# Official docker file for building HuntJS powered applications
#

FROM fedora:23

# Install dependencies
RUN dnf upgrade -y && dnf clean all
RUN dnf install -y gcc-c++ make dnf-plugins-core krb5-libs krb5-devel

# Enable copr repo with more recent nodejs versions
RUN dnf -y copr enable nibbler/nodejs
RUN dnf -y install git nodejs nodejs-devel npm

# Clean cache
RUN dnf -y clean all

# Listen on 3000 port
ENV PORT=3000
EXPOSE 3000

# Set nodejs environment
ENV NODE_ENV=production

# Set application parameters
ENV SECRET=someRealyLongStringToMakeHackersSad
ENV ADMIN_EMAIL=my.mail@mymail.com
ENV HUNTJS_ADDR=0.0.0.0

# Set hostname to react on and make redirects
ENV HOST_URL=http://myhuntjsapp.local

# Set database connection strings
ENV REDIS_URL=redis://huntjs:someRedisAuth@redis.local:6379
ENV MONGO_URL=mongodb://dbuser:dbpasswd@mongodb.local/dbname

#Set up the OAuth tokens for Google+
ENV GOOGLE_CLIENT_ID=
ENV GOOGLE_CLIENT_SECRET=

#Set up the OAuth tokens for Github
ENV GITHUB_CLIENT_ID=
ENV GITHUB_CLIENT_SECRET=

#Set up the OAuth tokens for Twitter
ENV TWITTER_CONSUMER_KEY=
ENV TWITTER_CONSUMER_SECRET=

#Set up the OAuth tokens for Facebook
ENV FACEBOOK_APP_ID=
ENV FACEBOOK_APP_SECRET=

#Set up the OAuth tokens for VK
ENV VK_APP_ID=
ENV VK_APP_SECRET=

# Inject code of your application
RUN rm -rf /srv
ADD . /srv

# Install dependencies
WORKDIR /srv
RUN npm install

# Run the image process. Point second argument to your entry point of application
CMD ["/usr/bin/node","/srv/examples/index.js"]

# For your application it can be something like this
# CMD ["/usr/bin/node","/path/to/your/huntjs/application/index.js"]