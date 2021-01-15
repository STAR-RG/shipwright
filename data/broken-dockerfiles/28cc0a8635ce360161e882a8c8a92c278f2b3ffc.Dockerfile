FROM rocker/verse:3.3
MAINTAINER Damir Perisa

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
  jags \
  mercurial gdal-bin libgdal-dev gsl-bin libgsl-dev \ 
  libc6-i386

RUN wget -nd -P /tmp http://pj.freefaculty.org/Debian/squeeze/amd64/openbugs_3.2.2-1_amd64.deb
RUN dpkg -i /tmp/openbugs_3.2.2-1_amd64.deb && rm /tmp/openbugs_3.2.2-1_amd64.deb 

RUN install2.r --error \
  --repos "https://stat.ethz.ch/CRAN/" \
  rstan \
  rstantools \ 
  rstanarm \
  bayesplot \
  brms \
  tidybayes
  
RUN install2.r --error \
  --repos "https://stat.ethz.ch/CRAN/" \
  rjags \
  R2jags \  
  R2OpenBUGS \
  rgdal 
  
RUN install2.r --error \
  --repos "https://inla.r-inla-download.org/R/stable" \
  INLA 
