# Inherit from node base image
FROM node

# This is an alternative to mounting our source code as a volume.
# ADD . /app

# Install Yarn repository
RUN curl -sS http://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install OS dependencies
RUN apt-get update
RUN apt-get install yarn

# Install Node dependencies
RUN yarn install