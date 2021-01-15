FROM python:2.7
RUN mkdir -p /service
ADD requirements.txt /service/requirements.txt
WORKDIR /service/
RUN pip install git+https://github.com/cuappdev/appdev.py.git --upgrade
RUN pip install -r requirements.txt
ADD blueprints blueprints
ADD src src
WORKDIR /service/src/scripts
CMD python setup_db.py dev;cd ..;python -u run.py