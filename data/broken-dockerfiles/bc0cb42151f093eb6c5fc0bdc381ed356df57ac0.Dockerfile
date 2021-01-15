FROM python:3.6

# Install pipenv
ADD https://raw.github.com/kennethreitz/pipenv/master/get-pipenv.py /get-pipenv.py
RUN python /get-pipenv.py && rm /get-pipenv.py

WORKDIR /app

# Add source code
COPY Makefile Pipfile Pipfile.lock /app/

# Install dependencies
RUN make init

COPY . /app

# Run app
EXPOSE 5000
CMD make serve
