FROM mhart/alpine-node:6

WORKDIR /opt/validator
ADD . .

RUN npm install

EXPOSE 80
EXPOSE 443
CMD ["npm", "start"]
