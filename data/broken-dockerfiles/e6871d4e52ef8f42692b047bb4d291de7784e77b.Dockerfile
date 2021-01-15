FROM 017940900017.dkr.ecr.us-west-2.amazonaws.com/stack-snapshots-core:lts-10.10

WORKDIR /app

COPY . /app
RUN stack build
