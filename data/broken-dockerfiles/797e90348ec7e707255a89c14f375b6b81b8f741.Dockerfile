FROM python:2.7
RUN apt-get update -qq && apt-get install -qy netcat
ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
ADD requirements.txt /code/
RUN pip install -r requirements.txt
ADD . /code/
RUN SECRET_KEY=unset python manage.py collectstatic --no-input
CMD gunicorn {{ project_name }}.wsgi -b 0.0.0.0:8000 --log-file - --access-logfile - -k eventlet --workers 4 --worker-connections 5
