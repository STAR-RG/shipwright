FROM python:3
ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
COPY requirements/common.pip /code/

# install pip requirements
RUN pip install -r common.pip --src /usr/local/src

# also install gunicorn
RUN pip install gunicorn==19.9.0 --src /usr/local/src

COPY . /code/

# collect static files
RUN python manage.py collectstatic --no-input

# expose the port 8000
EXPOSE 8000
