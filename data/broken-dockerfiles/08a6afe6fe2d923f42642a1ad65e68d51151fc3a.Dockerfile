
# ToDo: Finish this according to the guide
# https://docs.docker.com/get-started/part2/#tag-the-image
# and to check if scrapy needs an additional settings:
# https://github.com/scrapy-plugins/scrapy-splash

# Use an Floydhub deeplearning docker as a parent image
# https://github.com/floydhub/dl-docker
FROM floydhub/dl-docker:cpu
# FROM python:3.6

# Set the working directory of keep-current to /src
WORKDIR /src

# Copy the current directory contents into the container at /keep-current
ADD . /src

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Make port 9090 available to the world outside this container
EXPOSE 9090

# Define environment variable
ENV NAME World

# Run app.py when the container launches
CMD ["python", "keepcurrent/main.py"]