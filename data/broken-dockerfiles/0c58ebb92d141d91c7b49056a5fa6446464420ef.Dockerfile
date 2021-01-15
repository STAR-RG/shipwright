FROM python:3.7-alpine

WORKDIR /usr/src/app

RUN apk --no-cache update \
  && apk --no-cache add ca-certificates python python-dev py-pip py-setuptools groff less \
                        alpine-sdk gcc linux-headers make musl-dev python-dev \
  && apk --no-cache add --virtual build-dependencies curl \
  && apk del --purge build-dependencies

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5410

COPY . .
RUN python -m grpc_tools.protoc --proto_path=. ./entity.proto --python_out=. --grpc_python_out=.

CMD [ "python", "./nudnik.py", "--server" ]
