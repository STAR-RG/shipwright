FROM alpine:latest
MAINTAINER Antonios A. Chariton <daknob@daknob.net>

# Install Python 3 and pip3
RUN apk add --update python3
RUN python3 -m ensurepip
RUN pip3 install --upgrade pip setuptools

# Install a Production WSGI Web Server
RUN pip3 install gunicorn

# Install git
RUN apk add git

# Move everything inside the container
RUN mkdir /torpaste
COPY . /torpaste/.

# Change Directory to the TorPaste Path
WORKDIR /torpaste

# Install the required software
RUN pip3 install -r requirements.txt

# Pull more data from git
RUN git pull --depth=100

# Expose port *80*
EXPOSE 80

# Expose volume for persistence
VOLUME ["/torpaste/pastes"]

# Run the webserver with 8 workers
CMD ["gunicorn", "-w", "8", "-b", "0.0.0.0:80", "torpaste:app", "gunicorn-scripts"]
