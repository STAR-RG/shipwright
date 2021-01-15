# DESCRIPTION:  Sphinx server
# AUTHOR:       Daniel Mizyrycki <mzdaniel@glidelink.net>
#
# COMMENTS:     sphinxserve is a tool to effectively document projects
#               Using a docker volume, it monitors a sphinx directory, renders
#               and http serves the results when the source documents change.
#               This docker image is based in the python package sphinxserve
#               https://pypi.python.org/pypi/sphinxserve
#
# TO BUILD:     docker build -t mzdaniel/sphinxserve .
#
# HELP:         docker run mzdaniel/sphinxserve --help
#
# TO INSTALL:   # creating ~/bin/sphinxserve (small script calling docker)
#               docker run mzdaniel/sphinxserve install | bash
#
# TO RUN:       ~/bin/sphinxserve [SPHINX_DOCS_PATH]
#                       or
#               docker run -it -v $PWD:/host -p 8888:8888 \
#                   mzdaniel/sphinxserve [SPHINX_DOCS_PATH]

FROM alpine
MAINTAINER Daniel Mizyrycki mzdaniel@glidelink.net

ADD . /tmp/sphinxserve

# Build and install sphinxserve_pex wheel
RUN \
    mkdir /tmp/pkg /.pex && \
    chown 1000 /.pex && \
    apk update && \
    apk add curl sudo python alpine-sdk python-dev libffi-dev openssl-dev && \
    curl https://bootstrap.pypa.io/get-pip.py | python && \
    pip install wheel tox && \
    pip wheel --wheel-dir=/tmp/pkg "gevent>=1.1b2" && \
    sed -Ei 's|(sphinx<1.3)|\1 -f /tmp/pkg|' /tmp/sphinxserve/tox.ini && \
    cd /tmp/sphinxserve; tox -e build && \
    pip install -U /tmp/sphinxserve/dist/sphinxserve_pex*.whl && \
    apk del curl alpine-sdk python-dev libffi-dev openssl-dev && \
    pip uninstall -y wheel tox virtualenv && \
    rm -rf /var/cache/apk/* /root/.cache /tmp/* && \
    find /usr/lib/python2.7 \( -name '*.py' -o -name '*.pyo' \) -exec rm {} \;

ENTRYPOINT ["/usr/bin/sphinxserve"]
