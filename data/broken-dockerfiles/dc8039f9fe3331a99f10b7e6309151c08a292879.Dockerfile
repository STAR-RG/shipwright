FROM python:2.7

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY requirements.txt /usr/src/app/
RUN pip install -r requirements.txt

COPY . /usr/src/app

RUN pip install -e .

# The default command needs to be run with -it, but is the only
# non-parameterized entry point so the only thing that makes sense to add here
# right now.
CMD ["pgshovel", "shell"]
