FROM node:erbium-slim

EXPOSE 3000
WORKDIR /usr/src/krddevdays

COPY package*.json ./
RUN NODE_ENV=production npm ci

COPY . .
RUN npm run build

CMD [ "npm", "start" ]
