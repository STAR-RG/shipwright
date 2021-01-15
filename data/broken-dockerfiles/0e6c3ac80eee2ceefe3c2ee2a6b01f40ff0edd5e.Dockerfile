# 1. build the image locally
# docker build -t vanessa/sorting-hat .
#
# 2. map to localhost for rtweet verification, and provide your Twitter username
# docker run -p 80:80 vanessa/sorting-hat vsoch
# 
FROM r-base
RUN mkdir /code
WORKDIR /code
ADD . /code
RUN apt-get update && apt-get install -y openssl libssl-dev curl libcurl4-openssl-dev

# This is inefficient, I'm ok with it :)
RUN Rscript -e "install.packages('httr')"
RUN Rscript -e "install.packages('curl')"
RUN Rscript -e "install.packages('openssl')"
RUN Rscript -e "install.packages('devtools')"
RUN Rscript -e "install.packages('dplyr')"
RUN Rscript -e "install.packages('httpuv')"
RUN Rscript -e "devtools::install_github('mkearney/rtweet')"
ENTRYPOINT ["Rscript", "/code/sorting_code.R"]
