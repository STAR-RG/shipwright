FROM debian
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    python3-pip
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get install -y nodejs
WORKDIR /root/
RUN git clone https://github.com/thegroovebox/groovebox.org.git
WORKDIR /root/groovebox.org/
RUN pip3 install -e .
WORKDIR /root/groovebox.org/groovebox/static/
RUN npm install .
RUN ./node_modules/.bin/gulp styles
WORKDIR /root/groovebox.org/groovebox/
EXPOSE 8080
CMD python3 app.py