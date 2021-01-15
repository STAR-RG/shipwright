FROM node
COPY . .
RUN npm install
RUN npm run build-styles
EXPOSE 3000
CMD ["node", "index.js"]
