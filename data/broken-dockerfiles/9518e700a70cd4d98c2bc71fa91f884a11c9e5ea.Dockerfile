FROM debian:jessie

MAINTAINER Genar Trias <genar@cirici.com>

RUN apt-get clean && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    gdebi \
    wget \
    python-pip

WORKDIR /tmp

RUN wget http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb && \
    gdebi --n wkhtmltox-0.12.2.1_linux-jessie-amd64.deb && \
    rm wkhtmltox-0.12.2.1_linux-jessie-amd64.deb

RUN ln -s /usr/local/bin/wkhtmltopdf /usr/bin/wkhtmltopdf
RUN ln -s /usr/local/bin/wkhtmltoimage /usr/bin/wkhtmltoimage

WORKDIR /

COPY app.py /app.py
COPY requeriments.txt /requeriments.txt

RUN pip install -r requeriments.txt

EXPOSE 80

CMD ["python","app.py"]
