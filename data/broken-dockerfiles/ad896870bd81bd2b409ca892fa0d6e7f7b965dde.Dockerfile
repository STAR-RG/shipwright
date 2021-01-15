FROM golang:1.6
RUN apt-get update
RUN apt-get install -y nodejs-legacy
RUN apt-get install -y npm
RUN apt-get install -y sqlite3 libsqlite3-dev
RUN go get github.com/astaxie/beego && go get github.com/beego/bee
RUN go get github.com/mattn/go-sqlite3
COPY . /go/src/github.com/tfolkman/budget
WORKDIR /go/src/github.com/tfolkman/budget
RUN npm install
RUN ./bootstrap.sh
EXPOSE 8080
CMD ["bee", "run"]
