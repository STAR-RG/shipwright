FROM mefellows/mono-static

MAINTAINER Matt Fellows <matt.fellows@onegeek.com.au>

ONBUILD WORKDIR /usr/src/app/build
CMD [ "sleep", "600" ]