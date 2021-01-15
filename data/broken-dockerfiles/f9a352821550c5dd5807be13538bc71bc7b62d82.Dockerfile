FROM node:alpine
ENV GOOGLE_APPLICATION_CREDENTIALS=./.keys/tea-project-211819-3fc7a9bf354f.json
ENV NODE_ENV=production
WORKDIR /usr/src/wana
LABEL name="What a nice API"
COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
COPY . .
RUN npm install 
EXPOSE 3030
CMD npm start