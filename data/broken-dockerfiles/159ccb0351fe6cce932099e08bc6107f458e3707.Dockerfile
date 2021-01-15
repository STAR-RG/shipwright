FROM node:10-slim

# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
      --no-install-recommends

RUN apt-get install -y git
RUN apt-get update && apt-get install -y dos2unix

ARG USER=pptruser
ARG HOME_DIR=/home/$USER
ARG TOOL_HOME=$HOME_DIR/flattening_tool

COPY . $TOOL_HOME
WORKDIR $TOOL_HOME

RUN dos2unix $TOOL_HOME/bin/run
RUN apt-get --purge remove -y dos2unix
RUN rm -rf /var/lib/apt/lists/*

# Add user so we don't need --no-sandbox.
# same layer as npm install to keep re-chowned files from using up several hundred MBs more space
RUN groupadd -r $USER && useradd -r -g $USER -G audio,video $USER \
    && mkdir -p $TOOL_HOME \
    && chown -R $USER:$USER $HOME_DIR

# Run everything after as non-privileged user.
USER $USER

RUN npm install

ENTRYPOINT ["bin/run"]
