FROM kennethjiang/octopi:python3

RUN apt-get install -y netcat

RUN pip3 install ipdb

COPY . /app

WORKDIR /app

RUN pip3 install -e ./

