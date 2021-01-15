FROM api6.hukaa.com:5000/hukaa_www:1.1

COPY . /data/app/Transformer
WORKDIR /data/app/Transformer

RUN cpanm -n Smart::Comments
RUN cpanm -n Text::Xslate

RUN rm -rf .git

CMD ["/usr/local/bin/starman", "--port", "5003", "--workers", "20", "transformer.psgi"]
