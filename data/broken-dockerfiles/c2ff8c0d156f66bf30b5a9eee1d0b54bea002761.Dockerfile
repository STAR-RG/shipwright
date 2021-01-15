FROM python:2.7

MAINTAINER SCoRe Lab Community <commuity@scorelab.org>

ARG BUILD_DATE
ARG VCS_REF

WORKDIR /home/BellyDynamic
COPY . .

RUN chmod +x setup.sh; sync; ./setup.sh


LABEL multi.org.label-schema.name="BellyDynamic" \
      multi.org.label-schema.description="A scalable framework to handle online and offline dynamic graph objects" \
      multi.org.label-schema.url="https://github.com/scorelab/BellyDynamic/wiki" \
      multi.org.label-schema.vcs-url="https://github.com/scorelab/BellyDynamic" \
      multi.org.label-schema.vcs-ref=$VCS_REF \
      multi.org.label-schema.build-date=$BUILD_DATE \
      multi.org.label-schema.vendor="Sustainable Computing Research Group" \
      multi.org.label-schema.version="" \
      multi.org.label-schema.schema-version="1.0"
