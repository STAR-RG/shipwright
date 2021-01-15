FROM ubuntu:latest
ADD . /code
MAINTAINER Rajdeep Dua "dua_rajdeep@yahoo.com"
RUN apt-get update -y
RUN apt-get install -y python-pip python-dev build-essential
WORKDIR /code
RUN pip install -r requirements.txt

CMD ["python", "FLASK-API/api/interface/data_clean.py"]
CMD ["python", "FLASK-API/api/interface/server.py 3000"]
CMD ["python", "FLASK-API/api/interface/client.py"]
