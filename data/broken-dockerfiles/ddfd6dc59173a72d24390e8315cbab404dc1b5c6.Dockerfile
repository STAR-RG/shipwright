FROM python:3.6

# We're setting the workdir in docker
WORKDIR /code

# Adding requirements to docker
ADD requirements.txt ./

# Install all requirements
RUN pip install -r requirements.txt

# Rest of the code
ADD . /code

CMD ["./run.sh"]
