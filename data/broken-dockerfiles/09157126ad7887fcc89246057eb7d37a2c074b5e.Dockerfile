FROM node:9-alpine

# Install some system tools we need
RUN apk update && apk add git

# Tell node we are running in prod
ARG NODE_ENV=production
ENV NODE_ENV $NODE_ENV

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm install

# Bundle app source
COPY . .

# Build the app
RUN npm run build

# Expose the port the app listens on
EXPOSE 3000

# Start the app
CMD [ "npm", "start" ]
