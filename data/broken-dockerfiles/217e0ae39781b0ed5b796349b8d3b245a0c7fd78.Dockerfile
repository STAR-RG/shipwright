FROM debian:wheezy
MAINTAINER zhaoyao91

# setup environment
ENV DMETEOR_DIR /opt/dmeteor
COPY scripts $DMETEOR_DIR
RUN bash $DMETEOR_DIR/init.sh

# build app
ENV APP_SRC_DIR /app_src
ENV APP_DIR /app
ONBUILD COPY ./ $APP_SRC_DIR
ONBUILD RUN bash $DMETEOR_DIR/build_app.sh

# run app
EXPOSE 80
ENTRYPOINT bash $DMETEOR_DIR/run_app.sh