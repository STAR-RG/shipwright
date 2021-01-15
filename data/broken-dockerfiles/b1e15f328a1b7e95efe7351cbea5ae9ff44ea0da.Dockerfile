FROM python:3.6

COPY . /data

WORKDIR /data

RUN pip install -r ./requirements.txt

ENV CORE_SERVER_URL http://127.0.0.1:5002

EXPOSE 8000

CMD ["./start_server.bash"]