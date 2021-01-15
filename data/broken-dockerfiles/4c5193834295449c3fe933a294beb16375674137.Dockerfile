FROM python:3.6-slim-stretch

RUN apt update
RUN apt install -y python3-dev gcc wget curl

ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY app app/

ARG MODEL_URL
RUN wget -O modelDefinition.json $MODEL_URL

RUN python app/server.py

EXPOSE 5042


CMD ["python", "app/server.py", "serve"]