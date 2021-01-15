# pull official base image
FROM python:3.7.7-buster

# set work directory
WORKDIR /usr/src/

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install dependencies
RUN pip install --upgrade pip
COPY requirements.txt /usr/src/requirements.txt
RUN pip install -r ./requirements.txt

# copy project
COPY . /usr/src/
RUN rm app.db
RUN touch app.db
RUN flask db upgrade
EXPOSE 5000

CMD ["gunicorn", "-b", "0.0.0.0:5000", "run"]