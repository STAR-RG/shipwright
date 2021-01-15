FROM rocker/shiny-verse:3.6.1

RUN apt-get update && apt-get install -y  libsasl2-dev libssl-dev

RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl')" >> /usr/local/lib/R/etc/Rprofile.site

RUN R -e 'install.packages("remotes")'
RUN Rscript -e 'remotes::install_version("golem",upgrade="never", version = "0.1")'
RUN Rscript -e 'remotes::install_version("htmltools",upgrade="never", version = "0.4.0")'
RUN Rscript -e 'remotes::install_version("jsonlite",upgrade="never", version = "1.6")'
RUN Rscript -e 'remotes::install_version("cli",upgrade="never", version = "2.0.0")'
RUN Rscript -e 'remotes::install_version("mongolite",upgrade="never", version = "2.1.0")'
RUN Rscript -e 'remotes::install_version("purrr",upgrade="never", version = "0.3.2")'
RUN Rscript -e 'remotes::install_version("shiny",upgrade="never", version = "1.4.0")'

RUN mkdir /build_zone
ADD chuck /build_zone
WORKDIR /build_zone
RUN R -e 'remotes::install_local(upgrade = "never")'

ENV PORT=3838
ENV MONGOPORT=27017
ENV MONGOURL=127.0.0.1
ENV MONGODB=dockerdb
ENV MONGOCOLLECTION=dockercollec

EXPOSE $PORT

CMD R -e "options('shiny.port'=$PORT,shiny.host='0.0.0.0');chuck::run_app()"
