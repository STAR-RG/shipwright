FROM node:12.4.0-stretch-slim

# Run it from project root (docker build -f ./.storybook/DockerFile .)

WORKDIR /storybook

COPY package.json storybook
COPY yarn.lock storybook

RUN yarn install

COPY . storybook

RUN yarn build:storybook
CMD npx local-web-server -d ./storybook-static --spa index.html -p 3001 -z

EXPOSE 3001

