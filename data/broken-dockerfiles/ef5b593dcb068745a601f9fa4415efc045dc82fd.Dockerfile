FROM perl:{{version}}
MAINTAINER Rob Kinyon rob.kinyon@gmail.com

RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm Carton CPAN::Uploader

ENV app /app
RUN mkdir -p $app
WORKDIR $app

COPY "devops/within_carton" "/usr/local/bin/within_carton"
COPY "devops/MyConfig.pm" "/root/.cpan/CPAN/MyConfig.pm"
COPY "cpanfile" "/app/cpanfile"

RUN carton install

ENTRYPOINT [ "/usr/local/bin/within_carton" ]
CMD [ "prove", "-lrs" ]
