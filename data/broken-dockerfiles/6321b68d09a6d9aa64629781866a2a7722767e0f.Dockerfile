FROM node:12 AS assets

ADD . /opt/try-racket
WORKDIR /opt/try-racket
RUN npm install && npm run build

FROM jackfirth/racket:7.5-full AS distribution

ADD . /opt/try-racket
WORKDIR /opt/try-racket
COPY --from=assets /opt/try-racket/static /opt/try-racket/static
RUN find . -type d -name compiled | xargs rm -rf
RUN raco pkg install --auto try-racket/ \
  && raco setup -D --tidy --check-pkg-deps --unused-pkg-deps --pkgs try-racket

EXPOSE 8000
CMD ["racket", "try-racket/dynamic.rkt"]
