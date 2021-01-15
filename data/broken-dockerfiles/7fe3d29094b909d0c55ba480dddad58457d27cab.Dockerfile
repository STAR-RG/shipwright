FROM pypy:3-6-jessie

RUN apt-get update -y
RUN apt-get install -y python python-dev python-pip python3 python3-dev python3-venv python3-pip

RUN wget https://github.com/gmarcais/Jellyfish/releases/download/v2.2.10/jellyfish-2.2.10.tar.gz
RUN tar zxf jellyfish-2.2.10.tar.gz && rm -f jellyfish-2.2.10.tar.gz
RUN cd jellyfish-2.2.10 && ./configure --enable-python-binding && make && make install

RUN mkdir -p /environments/py3
RUN python3 -m venv /environments/py3

ADD requirements.txt /code/requirements.txt
ADD unit_test.sh /code/unit_test.sh

RUN bash -c "source /environments/py3/bin/activate && python -c \"import sys; print(sys.version)\" && python -m pip install -r /code/requirements.txt"
RUN bash -c "source /environments/py3/bin/activate && export PKG_CONFIG_PATH=/jellyfish-2.2.10 && cd /jellyfish-2.2.10/swig/python && python setup.py build && python setup.py install"

RUN bash -c "python -c \"import sys; print(sys.version)\" && python -m pip install -r /code/requirements.txt"
RUN export PKG_CONFIG_PATH=/jellyfish-2.2.10 && \
    cd /jellyfish-2.2.10/swig/python && \
    python setup.py build && \
    python setup.py install

RUN rm -rf /jellyfish-2.2.10

#RUN bash -c "pypy3 -c \"import sys; print(sys.version)\" && pypy3 -m pip install -r /code/requirements.txt"
#RUN export PKG_CONFIG_PATH=/jellyfish-2.2.10 && cd /jellyfish-2.2.10/swig/python && pypy3 setup.py build && pypy3 setup.py install

ADD experiment /code/experiment
ADD src /code/src
ADD test /code/test

RUN echo "*** Python 2 ***"
RUN bash -c "cd /code && python `which py.test` src/*.py"
RUN bash -c "cd /code && ./test/sm.sh python"

RUN echo "*** Python 3 ***"
RUN bash -c "source /environments/py3/bin/activate && cd /code && python `which py.test` src/*.py"
RUN bash -c "source /environments/py3/bin/activate && cd /code && ./test/sm.sh python"

#RUN echo "*** Pypy 3 ***"
#RUN bash -c "cd /code && pypy3 `which py.test` src/*.py"
#RUN bash -c "cd /code && ./test/sm.sh pypy3"
