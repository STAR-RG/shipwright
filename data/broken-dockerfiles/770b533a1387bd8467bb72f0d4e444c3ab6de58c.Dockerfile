FROM blacktop/yara

LABEL maintainer "https://github.com/blacktop"

LABEL malice.plugin.repository = "https://github.com/malice-plugins/office.git"
LABEL malice.plugin.category="office"
LABEL malice.plugin.mime="application/vnd.ms-*"
LABEL malice.plugin.docker.engine="*"

ENV DIDIER_URL https://didierstevens.com/files/software
ENV OLEDUMP_URL ${DIDIER_URL}/oledump_V0_0_33.zip
ENV RTFDUMP_URL ${DIDIER_URL}/rtfdump_V0_0_6.zip
ENV YARA_RULES ${DIDIER_URL}/yara-rules-V0.0.8.zip

COPY . /usr/sbin
RUN apk --update add --no-cache python py-setuptools file
RUN apk --update add --no-cache -t .build-deps \
  openssl-dev \
  build-base \
  python-dev \
  libffi-dev \
  musl-dev \
  libc-dev \
  py-pip \
  gcc \
  git \
  && set -ex \
  && echo "===> Install oletools..." \
  && export PIP_NO_CACHE_DIR=off \
  && export PIP_DISABLE_PIP_VERSION_CHECK=on \
  && pip install --upgrade pip wheel \
  && pip install https://github.com/decalage2/olefile/zipball/master \
  && pip install https://github.com/decalage2/oletools/zipball/master \
  && echo "===> Fixing error in oledir.py" \
  && sed -i 's/from thirdparty.colorclass import colorclass/from thirdparty.colorclass import color/' /usr/lib/python2.7/site-packages/oletools/oledir.py \
  && chmod +x /usr/lib/python2.7/site-packages/oletools/*.py \
  && ln -s /usr/lib/python2.7/site-packages/oletools/ezhexviewer.py /usr/local/bin/ezhexviewer \
  && ln -s /usr/lib/python2.7/site-packages/oletools/mraptor.py /usr/local/bin/mraptor \
  && ln -s /usr/lib/python2.7/site-packages/oletools/olebrowse.py /usr/local/bin/olebrowse \
  && ln -s /usr/lib/python2.7/site-packages/oletools/oledir.py /usr/local/bin/oledir \
  && ln -s /usr/lib/python2.7/site-packages/oletools/oleid.py /usr/local/bin/oleid \
  && ln -s /usr/lib/python2.7/site-packages/oletools/olemap.py /usr/local/bin/olemap \
  && ln -s /usr/lib/python2.7/site-packages/oletools/olemeta.py /usr/local/bin/olemeta \
  && ln -s /usr/lib/python2.7/site-packages/oletools/oleobj.py /usr/local/bin/oleobj \
  && ln -s /usr/lib/python2.7/site-packages/oletools/oletimes.py /usr/local/bin/oletimes \
  && ln -s /usr/lib/python2.7/site-packages/oletools/olevba.py /usr/local/bin/olevba \
  && ln -s /usr/lib/python2.7/site-packages/oletools/ppt_parser.py /usr/local/bin/ppt_parser \
  && ln -s /usr/lib/python2.7/site-packages/oletools/pyxswf.py /usr/local/bin/pyxswf \
  && ln -s /usr/lib/python2.7/site-packages/oletools/rtfobj.py /usr/local/bin/rtfobj \
  && echo "===> Install oledump..." \
  && curl -Ls ${OLEDUMP_URL} > /tmp/oledump.zip \
  && cd /tmp \
  && mkdir -p /opt/oledump \
  && unzip oledump.zip -d /opt/oledump \
  && chmod +x /opt/oledump/oledump.py  \
  && ln -s /opt/oledump/oledump.py /usr/local/bin/oledump \
  && echo "===> Install rtfdump..." \
  && curl -Ls ${RTFDUMP_URL} > /tmp/rtfdump.zip \
  && mkdir -p /opt/rtfdump \
  && unzip rtfdump.zip -d /opt/rtfdump \
  && chmod +x /opt/rtfdump/rtfdump.py  \
  && ln -s /opt/rtfdump/rtfdump.py /usr/local/bin/rtfdump \
  && echo "===> Install ViperMonkey..." \
  && curl -Ls https://github.com/decalage2/ViperMonkey/archive/master.zip > /tmp/ViperMonkey.zip \
  && unzip ViperMonkey.zip \
  && mv ViperMonkey-master/vipermonkey /opt/vipermonkey \
  && cd /opt/vipermonkey \
  && pip install prettytable colorlog colorama pyparsing \
  && chmod +x vmonkey.py vbashell.py \
  && ln -s /opt/vipermonkey/vmonkey.py /usr/local/bin/vmonkey \
  && ln -s /opt/vipermonkey/vbashell.py /usr/local/bin/vbashell \
  && echo "===> Install malice/office plugin..." \
  && cd /usr/sbin \
  && export PIP_NO_CACHE_DIR=off \
  && export PIP_DISABLE_PIP_VERSION_CHECK=on \
  && pip install --upgrade pip wheel \
  && echo "\t[*] install requirements..." \
  && pip install -U -r requirements.txt \
  && pip list \
  && echo "\t[*] install office.py..." \
  && chmod +x office.py \
  && ln -s /usr/sbin/office.py /usr/sbin/office \
  && echo "\t[*] clean up..." \
  && cd /usr/lib/python2.7/site-packages/oletools \
  && find . ! -name '*.py*' -type f -exec rm -f {} + && rm -rf doc \
  && cd /usr/lib/python2.7/site-packages/olefile \
  && find . ! -name '*.py*' -type f -exec rm -f {} + && rm -rf doc \
  && rm requirements.txt Dockerfile \
  && apk del --purge .build-deps

WORKDIR /malware

ENTRYPOINT ["/bin/office"]
CMD ["--help"]
