FROM swift:latest

COPY . /lambda
RUN cd /lambda/Example; swift build -c release
RUN cp /lambda/Example/.build/x86_64-unknown-linux/release/Example /lambda/Example/.build/x86_64-unknown-linux/release/bootstrap
