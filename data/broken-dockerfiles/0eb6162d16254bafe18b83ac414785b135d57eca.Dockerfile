FROM r-base:3.5.2

# system libraries of general use
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libxml2-dev

COPY . /app
RUN Rscript /app/install-requirements.R

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/app', port=3838, host = '0.0.0.0')"]
