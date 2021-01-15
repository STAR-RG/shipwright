FROM google/dart:2.5
WORKDIR /build/
ADD pubspec.yaml .
RUN pub get --no-precompile
FROM scratch
