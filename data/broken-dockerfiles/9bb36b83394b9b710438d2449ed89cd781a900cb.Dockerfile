FROM jerret321/puppeteer-linux
USER root
COPY . $DIR
WORKDIR $DIR
VOLUME $DIR/logs
VOLUME $DIR/download

# huaban.com
# ENV huaban_pass 
# ENV huaban_mobile 

RUN npm i --registry=https://registry.npm.taobao.org \  
    && npm i pm2 -g --registry=https://registry.npm.taobao.org \
    && chown -R pptruser:pptruser /usr/local/lib/node_modules \
    && chown -R pptruser:pptruser $DIR/logs \
    && chown -R pptruser:pptruser ./node_modules \
    && chown -R pptruser:pptruser $DIR/download

# USER pptruser

# CMD ["pm2-runtime", "pm2.json"]
