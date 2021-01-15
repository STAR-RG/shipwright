FROM ubuntu
MAINTAINER Itxaka Serrano Garcia <itxakaserrano@gmail.com>

# Update the repositories
RUN apt-get update

# Install git and pip
RUN apt-get install -y git-core python-pip

# Clone the repository
RUN git clone https://github.com/Itxaka/Gobolino.git /var/www/

# Install the requirements
RUN pip install -r /var/www/web/requirements.txt

# Create a random secret key
RUN sed -i "s/SECRET_KEY = ''/SECRET_KEY = '`tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1`'/g" /var/www/web/config.py

# Change the server to run on all ips
RUN sed -i 's/HOST = "127.0.0.1"/HOST = "0.0.0.0"/g' /var/www/web/config.py

# Create an admin user
RUN python /var/www/web/createuser.py admin admin

# Open port 5000
EXPOSE 5000

# Run the server on container launch
CMD python /var/www/web/runserver.py
