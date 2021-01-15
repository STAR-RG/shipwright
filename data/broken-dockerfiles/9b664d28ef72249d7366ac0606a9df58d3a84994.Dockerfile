FROM rocker/rstudio:latest

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  libxml2-dev \
  libcairo2-dev \
  libsqlite3-dev \
  libmariadbd-dev \
  libmariadb-client-lgpl-dev \
  libpq-dev \
  libssh2-1-dev \
  unixodbc-dev \
  libgeos-dev \
  libudunits2-dev \
  libgdal-dev
RUN R -e "install.packages(c('rgeos','sf','units'),type='source')" 
RUN R -e "source('https://bioconductor.org/biocLite.R')" \
  && install2.r --error \
    --deps TRUE \
    tidyverse \
    dplyr \
    ggplot2 \
    devtools \
    formatR \
    remotes \
    selectr \
    caTools \
  && R -e "library(BiocInstaller); biocLite(c('openCyto','COMPASS','MIMOSA','CytoML','ggcyto'))" 
# not clear why selectr needs explicit re-install, see https://github.com/rocker-org/rocker-versioned/pull/63

## Notes: Above install2.r uses --deps TRUE to get Suggests dependencies as well,
## dplyr and ggplot are already part of tidyverse, but listed explicitly to get their (many) suggested dependencies.
## In addition to the the title 'tidyverse' packages, devtools is included for package development.
## RStudio wants formatR for rmarkdown, even though it's not suggested.
## remotes included for installation from heterogenous sources including git/svn, local, url, and specific cran versions
