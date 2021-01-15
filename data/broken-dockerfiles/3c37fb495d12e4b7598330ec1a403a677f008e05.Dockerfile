FROM kaggle/python:latest

RUN pip install bottle
RUN mkdir -p /usr/src/app

COPY server.py /usr/src/app/server.py

EXPOSE 8080

WORKDIR /usr/src/app

CMD [ "python", "./server.py" ]

# docker build -t predict .
# docker run -p 4000:8080 predict