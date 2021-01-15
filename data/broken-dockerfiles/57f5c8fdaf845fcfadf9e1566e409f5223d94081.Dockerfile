FROM rocker/r-devel
MAINTAINER Noam Ross noam.ross@gmail.com

# A Dockerfile with dependencies for testing the package against development R

RUN rm -rf /var/lib/apt/lists/ \
  && apt-get update \
  && apt-get install -y -t unstable --no-install-recommends \
    libcurl4-openssl-dev \
    libssl1.0.0 \
    libssl-dev \
    libv8-3.14-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/

RUN install2.r -r http://cran.rstudio.com \
    httr \
    V8 \
    covr \
    testthat
