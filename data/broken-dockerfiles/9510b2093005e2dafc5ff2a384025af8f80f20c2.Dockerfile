from elasticsearch

RUN apt-get --fix-missing update --fix-missing
RUN apt-get -yq install python-dev python-pip nginx tesseract-ocr imagemagick libyaml-dev

COPY legisletters /legisletters
COPY default /etc/nginx/sites-available/default

RUN pip install -r /legisletters/requirements.txt
RUN plugin install elasticsearch/elasticsearch-mapper-attachments/2.5.0
