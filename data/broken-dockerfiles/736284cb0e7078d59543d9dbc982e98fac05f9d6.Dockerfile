## -*- docker-image-name: "sje30/waverepo" -*-
FROM rocker/verse
MAINTAINER Stephen Eglen <sje30@cam.ac.uk>

ENV PROJ /home/rstudio/waverepo
RUN mkdir $PROJ
RUN pwd
RUN git clone https://github.com/sje30/waverepo.git $PROJ

WORKDIR $PROJ/paper
RUN make rpackages
RUN make

RUN mkdir codecheck

RUN date > codecheck/date.txt
RUN uname -a > codecheck/uname.txt
RUN cp figure/CIplot-1.pdf codecheck
RUN cp figure/nelec-durn-fig-1.pdf codecheck
RUN cp figure/wong-ci-fig-1.pdf codecheck
RUN cp figure/Xu-CI-plot-1.pdf codecheck

WORKDIR $PROJ/paper/codecheck
RUN ls > MANIFEST

## Tips taken from Ben Marwick's Dockerfile
## https://github.com/benmarwick/1989-excavation-report-Madjebebe/blob/master/Dockerfile
##
## To rebuild:
## docker build -t sje30/waverepo https://raw.githubusercontent.com/sje30/waverepo/master/Dockerfile
