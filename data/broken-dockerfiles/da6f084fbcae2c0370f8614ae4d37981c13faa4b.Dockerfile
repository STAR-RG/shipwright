
FROM golang:1.10.1 as builder

#作者
MAINTAINER yongtao.yin "yongtao.yin@bsit.cn"

# 安装 xz
RUN apt-get update && apt-get install -y \
    xz-utils \
&& rm -rf /var/lib/apt/lists/*

#安装 UPX 压缩工具
ADD https://github.com/upx/upx/releases/download/v3.95/upx-3.95-amd64_linux.tar.xz /usr/local

RUN xz -d -c /usr/local/upx-3.95-amd64_linux.tar.xz | \
    tar -xOf - upx-3.95-amd64_linux/upx > /bin/upx && \
    chmod a+x /bin/upx

#安装项目的依赖包，使用govender之后不需要安装了
#RUN go get github.com/gin-gonic/gin

#设置工作目录
WORKDIR $GOPATH/src/gin-first

#添加工作目录
ADD . $GOPATH/src/gin-first

#运行编译
RUN go build .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o gin-first .

#压缩编译后的二进制文件
RUN strip --strip-unneeded gin-first
RUN upx gin-first

#使用最小的 alpine镜像
FROM alpine:3.8
#设置语言格式
ENV LANG=C.UTF-8
#设置时区
RUN apk add tzdata && ls /usr/share/zoneinfo && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone

#添加ca-certificates 如果有需要
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*

#设置工作目录
WORKDIR /root

#从编译器里 copy 二进制文件
COPY --from=builder /go/src/gin-first/gin-first .
COPY --from=builder /go/src/gin-first/view/ ./view/
COPY --from=builder /go/src/gin-first/conf/ ./conf/
COPY --from=builder /go/src/gin-first/logs  ./logs

#运行二进制文件
CMD ["./gin-first"]