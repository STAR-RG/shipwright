
FROM python:3.6


LABEL Name=meta-music Version=0.0.1
EXPOSE 5000

ADD ./requirements.txt /app/requirements.txt

WORKDIR /app


RUN apt-get -y update
RUN apt-get install -y ffmpeg
RUN apt-get install -y libportaudio2 
RUN pip install -r requirements.txt
RUN apt-get install -y nano
ADD . /app 

CMD ["python3", "app.py"]


