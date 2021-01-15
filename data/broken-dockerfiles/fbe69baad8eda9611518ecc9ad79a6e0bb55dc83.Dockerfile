FROM node:8.6.0-alpine

# Set a working directory
WORKDIR /usr/src/app

COPY ./package.json .
COPY ./yarn.lock .

# Install Node.js dependencies
RUN yarn install --production --no-progress

# Copy application files
COPY ./build .

# Run the container under "node" user by default
USER node
EXPOSE 3000
CMD [ "node", "server.js" ]
