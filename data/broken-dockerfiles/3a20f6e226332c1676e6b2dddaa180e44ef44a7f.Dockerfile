FROM img.reg.3g:15000/ubuntu-base:v3
MAINTAINER xueying.zheng@yeepay.com
ADD /src/sso/conf /conf
ADD Manifest /
ADD Dockerfile /
ADD src/sso/main /sso

ENTRYPOINT ["/sso"]