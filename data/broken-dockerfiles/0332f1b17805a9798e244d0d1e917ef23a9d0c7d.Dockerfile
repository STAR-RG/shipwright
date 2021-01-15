ARG BASE_IMAGE=ubuntu:18.04
FROM $BASE_IMAGE

WORKDIR /opt/app/
COPY wallets/requirement.txt ./
RUN pip3 install --no-cache-dir -r requirement.txt
COPY wallets/package.json package.json
RUN npm install
COPY wallets/ wallets/
COPY common/ common/

ENTRYPOINT bash wallets/bootstrap.sh