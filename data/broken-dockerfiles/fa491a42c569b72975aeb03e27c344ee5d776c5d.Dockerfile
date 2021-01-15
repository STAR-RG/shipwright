FROM node:5

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Copy all the files
COPY . /usr/src/app

# Install app dependencies
RUN npm install

# Build the app
RUN npm run build

EXPOSE 8880

CMD [ "npm", "run", "start" ]
