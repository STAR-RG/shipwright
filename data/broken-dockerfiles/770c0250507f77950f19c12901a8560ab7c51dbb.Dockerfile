FROM docker.sebastian-daschner.com/open-liberty:2

ENV JVM_ARGS="-Xmx512M --add-opens java.base/java.net=ALL-UNNAMED"

COPY target/instrument-craft-shop.war $DEPLOYMENT_DIR
