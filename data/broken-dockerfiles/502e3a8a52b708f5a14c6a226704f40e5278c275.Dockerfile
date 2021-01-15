FROM node:8.5
WORKDIR /usr/leadcoin
COPY  ./ ./


# A default .env. Should be overridden by docker when you executing it.
# for e.g. "sudo docker run -v /home/build/.env:/usr/leadcoin/backend/.env --network host --name backend --rm leadcoin/leadcoin
copy ./backend/.env.example ./backend/.env

WORKDIR /usr/leadcoin
RUN npm i --quiet

WORKDIR /usr/leadcoin/backend
RUN npm i --quiet

CMD ["npm", "start"]
