FROM golang:alpine as build

WORKDIR /build

RUN true \
	&& apk --no-cache add \
		git

RUN true \
    && go get -u github.com/zricethezav/gitleaks

# ---

FROM opendevsecops/launcher:latest as launcher

# ---

FROM alpine:latest

WORKDIR /run

RUN true \
	&& apk --no-cache add \
		git \
		openssh

ADD configs configs

COPY --from=build /go/bin/gitleaks /bin/gitleaks

COPY --from=launcher /bin/launcher /bin/launcher

WORKDIR /session

ENTRYPOINT ["/bin/launcher", "/bin/gitleaks"]
