FROM python:3.7-alpine

# Container setup
EXPOSE 4040
VOLUME /config
VOLUME /archive

# Copy project to build context
WORKDIR /app
COPY . /app

# Install Python dependencies
RUN apk add --update --no-cache g++ gcc libxslt-dev
RUN pip install -r requirements.txt

# Install Node, npm and install dependencies
WORKDIR /app/datahoarder-ui
RUN apk add --update nodejs nodejs-npm yarn
RUN yarn install
RUN yarn build
WORKDIR /app

# Start Datahoarder
CMD python app.py