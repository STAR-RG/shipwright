FROM python:2.7
RUN pip install flake8
ADD requirements.txt /widely/requirements.txt
RUN cd /widely && pip install -r requirements.txt
ADD . /widely
RUN cd /widely && flake8 .
RUN cd /widely && python -m unittest -f tests
RUN cd /widely && python setup.py install
