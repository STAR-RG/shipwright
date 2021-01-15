# This is a multi-stage Docker build

# Create the downloads collection
FROM python:3.8-slim as collection

WORKDIR /source/

COPY . /source/
RUN pip install -r requirements.txt
# Validate that what was installed was what was expected
RUN pip freeze 2>/dev/null | grep -v "deployer" > requirements.installed \
        && diff -u requirements.txt requirements.installed 1>&2 \
        || ( echo "!! ERROR !! requirements.txt defined different packages or versions for installation" \
                && exit 1 ) 1>&2

RUN python -m fetch_downloads

# Build the HTML from the source
FROM alpine as html

WORKDIR /source/

# Copy the Gemfiles, so the dependencies can be installed correctly
COPY Gemfile Gemfile.lock /source/

RUN apk --no-cache add \
        build-base \
        ruby \
        ruby-bigdecimal \
        ruby-dev \
        ruby-json \
        ruby-rdoc \
    && echo "gem: --no-ri --no-rdoc --no-document" > ~/.gemrc \
    && gem update --system \
    && gem install http_parser.rb -v 0.6.0 -- --use-system-libraries \
    && gem install safe_yaml -v 1.0.4 -- --use-system-libraries \
    && bundle update --bundler \
    && bundle install \
    && apk --no-cache del \
        build-base \
        ruby-dev

COPY . /source/
COPY --from=collection /source/_downloads /source/_downloads

RUN mkdir /html \
    && JEKYLL_ENV=production jekyll build --strict_front_matter -s /source -d /html

# Copy the HTML and serve it via nginx
FROM nginx:alpine

ARG BUILD_DATE=""
ARG BUILD_VERSION="dev"

LABEL maintainer="truebrain@openttd.org"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=${BUILD_DATE}
LABEL org.label-schema.version=${BUILD_VERSION}

COPY --from=html /html/ /usr/share/nginx/html/
RUN sed -i 's/access_log/# access_log/g' /etc/nginx/nginx.conf
COPY nginx.default.conf /etc/nginx/conf.d/default.conf
