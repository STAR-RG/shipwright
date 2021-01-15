# Use Node version 10
FROM mhart/alpine-node:10

# Lock python to 2.7 somehow TODO:
RUN apk update && apk add python make g++ git

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY /src /app
COPY .env.example .env

ENV PORT=8081

RUN touch /data/production.db

EXPOSE 8081
CMD [ "npm", "start" ]



# OLD VERSION
# Use Node version 10
# FROM mhart/alpine-node:10

# # Lock python to 2.7 somehowa
# RUN apk update && apk add python make g++ git
# # RUN git clone https://github.com/thechutrain/rc-coffee-chats.git app
# # RUN git checkout -t origin/v2.1

# WORKDIR /app
# COPY package.json /
# RUN npm install
# COPY /src /app

# COPY .env.example .env
# # RUN ["cp", ".env.example", ".env"] 
# ENV PORT=8081  

# RUN touch ./data/production.db

# EXPOSE 8081
# CMD [ "npm", "start" ]
