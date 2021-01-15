# This image is used to create bleeding edge docker image and is not compatible with any other image
FROM golang:1.8

# Copy sources
COPY . /go/src/gitlab.com/gitlab-org/gitlab-runner
WORKDIR /go/src/gitlab.com/gitlab-org/gitlab-runner

# Fetch tags (to have proper versioning)
RUN git fetch --tags || true

# Build development version
ENV BUILD_PLATFORMS -osarch=linux/amd64
RUN make && \
	ln -s $(pwd)/out/binaries/alloy-runner-linux-amd64 /usr/bin/alloy-ci-multi-runner && \
	ln -s $(pwd)/out/binaries/alloy-runner-linux-amd64 /usr/bin/alloy-runner

# Install runner
RUN packaging/root/usr/share/alloy-runner/post-install

# Preserve runner's data
VOLUME ["/etc/alloy-runner", "/home/alloy-runner"]

# init sets up the environment and launches gitlab-runner
CMD ["run", "--user=alloy-runner", "--working-directory=/home/alloy-runner"]
ENTRYPOINT ["/usr/bin/alloy-runner"]
