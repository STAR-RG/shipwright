FROM node:latest AS build-env
WORKDIR /app

# Prepare the dependencies
COPY package*.json /app/
RUN npm install && npm cache clean --force
# Copy everything else
COPY . /app
ARG NODE_ENV
ENV NODE_ENV $NODE_ENV
RUN npm run build


# Host as static website
FROM nginx:alpine
COPY --from=build-env /app/public/. /usr/share/nginx/html


# Runtime settings
EXPOSE 80
