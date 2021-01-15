#§ 'FROM node:' + data.config.npm.node.version + '-slim'
FROM node:10.15-slim

LABEL maintainer="Jędrzej Lewandowski <jedrzejblew@gmail.com>"

WORKDIR /app
ADD . /app

RUN bash -c 'set -o pipefail && \
    ( \
    if [[ "$(node --version)" = "$(cat .nvmrc)"* ]]; then \
    echo "Node version correct"; else echo "Node version in .nvmrc is different. Please update Dockerfile" && exit 1; fi \
    ) \
    && npm install \
    && npm run build \
    && npm install -g'

CMD ["wise daemon"]

HEALTHCHECK --interval=500s --timeout=15s --start-period=500s --retries=2 CMD [ "node", "container-healthcheck.js" ]

##§ '\n' + data.config.docker.generateDockerfileFrontMatter(data) + '\n' §##
LABEL maintainer="The Wise Team (https://wise-team.io/) <contact@wiseteam.io>"
LABEL vote.wise.wise-version="3.1.1"
LABEL vote.wise.license="MIT"
LABEL vote.wise.repository="steem-wise-cli"
##§ §.##