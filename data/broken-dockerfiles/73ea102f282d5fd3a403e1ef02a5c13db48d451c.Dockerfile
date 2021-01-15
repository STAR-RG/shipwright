FROM library/ubuntu
MAINTAINER cxmcc
RUN apt-get update -y
RUN apt-get install -y python-pip python-dev build-essential
RUN pip install flask
RUN mkdir /app
COPY ./app.py /app
WORKDIR /app
ENTRYPOINT ["python"]
CMD ["app.py"]
