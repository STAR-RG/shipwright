FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    python-pip wget bzip2 python-dev cmake \
    zip libboost-all-dev gunicorn \
    libsm6 libxext6 libfontconfig1 libxrender1

COPY . /app

WORKDIR /app/face_detection/data
RUN chmod +x models.sh && ./models.sh

WORKDIR /app
RUN pip install -r requirements.txt

EXPOSE 5000

CMD [ "gunicorn", "-b 0.0.0.0:5000", "server:app" ]