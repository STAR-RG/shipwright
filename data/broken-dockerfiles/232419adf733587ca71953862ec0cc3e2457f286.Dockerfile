FROM python:alpine

WORKDIR /bot

ADD . /bot

RUN pip install -r requirements.txt &&\
    cp settings.py.docker settings.py

EXPOSE 5000

CMD ["python", "runme.py"]
