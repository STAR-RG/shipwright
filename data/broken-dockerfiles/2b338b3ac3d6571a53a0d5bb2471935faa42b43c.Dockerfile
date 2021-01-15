#
# Elasticsearch Dockerfile
#
# https://github.com/dockerfile/elasticsearch
#

# Pull base image.
FROM elasticsearch:1.5.1

ADD http://stedolan.github.io/jq/download/linux64/jq /usr/local/bin/jq
RUN chmod +x /usr/local/bin/jq

ADD /start-elasticsearch-clustered.sh /
RUN chmod +x /start-elasticsearch-clustered.sh

RUN plugin -install mobz/elasticsearch-head

CMD ["/start-elasticsearch-clustered.sh"]
