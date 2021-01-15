# docker build -t while42/jekyll .
# docker run -d -v "$PWD:/src" -p 4000:4000 while42/jekyll serve -H 0.0.0.0

FROM ruby:2.2
MAINTAINER mose@mose.com

RUN apt-get update && apt-get install -y node python-pygments && apt-get clean
RUN gem install github-pages

VOLUME /src
EXPOSE 4000

WORKDIR /src
ENTRYPOINT ["jekyll"]
