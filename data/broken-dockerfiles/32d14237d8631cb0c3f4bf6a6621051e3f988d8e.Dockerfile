FROM alpine:3.9

ENV USER=dl-nhltv

RUN apk update -U && \
    apk add -U git aria2 ffmpeg python2 py-pip openssl && \
    rm -rf /tmp/* /var/cache/apk/*

RUN addgroup -S $USER && adduser -S -g $USER -u 1000 $USER

RUN git clone https://github.com/cmaxwe/dl-nhltv.git /app/dl-nhltv
RUN pip install /app/dl-nhltv

RUN mkdir /mediafiles
RUN chown dl-nhltv /mediafiles

USER dl-nhltv
WORKDIR /home/dl-nhltv

CMD ["/bin/sh" ]
