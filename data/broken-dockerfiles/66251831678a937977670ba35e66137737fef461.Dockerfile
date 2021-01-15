FROM django:onbuild
# FOR DEV ONLY

# who are we ?
MAINTAINER UrLab

# Add the path
ADD . /usr/src/app

# Update the default application repository sources list
RUN apt-get update && apt-get -y upgrade

# Install the packages needed
RUN apt-get install -y python3-dev python3-setuptools libtiff5-dev libjpeg62-turbo-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.5-dev tk8.5-dev

# South
RUN ./manage.py migrate

# create some superuser for ya
RUN echo "from django.contrib.auth import get_user_model; User = get_user_model() ;User.objects.create_superuser('admin', 'admin@example.com', 'admin')" | python manage.py shell
RUN echo "from django.contrib.auth import get_user_model; User = get_user_model() ;User.objects.create_superuser('root', 'root@example.com', 'root')" | python manage.py shell
RUN echo "from django.contrib.auth import get_user_model; User = get_user_model() ;User.objects.create_superuser('poney', 'poney@example.com', 'poney')" | python manage.py shell
