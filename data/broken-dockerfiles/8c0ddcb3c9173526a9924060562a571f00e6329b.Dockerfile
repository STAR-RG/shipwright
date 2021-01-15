# Наследуемся от CentOS 7
FROM centos:7

# Выбираем рабочую папку
WORKDIR /root

# Устанавливаем wget и скачиваем Go
RUN yum install -y wget && \
    yum install -y git && \
    # yum install -y net-tools && \
    wget https://storage.googleapis.com/golang/go1.11.4.linux-amd64.tar.gz

# Устанавливаем Go, создаем workspace и папку проекта
RUN tar -C /usr/local -xzf go1.11.4.linux-amd64.tar.gz && \
    mkdir go && mkdir go/src && mkdir go/bin && mkdir go/pkg && \
    mkdir go/src/dumb

# Задаем переменные окружения для работы Go
ENV PATH=${PATH}:/usr/local/go/bin GOROOT=/usr/local/go GOPATH=/root/go

# Копируем наш исходный main.go внутрь контейнера, в папку go/src/dumb
ADD main.go go/src/dumb

# Копируем пакеты
COPY go-path/src go/src

# Устанавливаем пакеты
# Компилируем и устанавливаем наш сервер
RUN go get -u github.com/valyala/fasthttp && \
    go get -u github.com/mailru/easyjson && \
    go get -u github.com/valyala/fastjson && \
    go build dumb && go install dumb

# Открываем 80-й порт наружу
EXPOSE 80


# sysctl -a | grep 'net.ipv4.tcp_window_scaling\|tcp_low_latency\|tcp_sack\|tcp_timestamps\|tcp_fastopen' &&\

# Запускаем наш сервер
#CMD ifconfig | grep mtu && head -n 26 /proc/cpuinfo && GODEBUG=memprofilerate=0 ./go/bin/dumb
CMD grep "model name" /proc/cpuinfo | head -n 1 && \
    cat /proc/version &&\
    GODEBUG=memprofilerate=0 ./go/bin/dumb
