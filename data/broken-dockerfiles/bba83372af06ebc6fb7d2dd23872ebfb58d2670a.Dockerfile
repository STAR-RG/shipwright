FROM python:2.7

WORKDIR "/src/demo"
EXPOSE 8080
VOLUME ["src"]

RUN pip install \
    Django==1.9.2 \
    uwsgi==2.0

# variant 1
ENTRYPOINT ["uwsgi"]
CMD ["--socket", "0.0.0.0:8080", "--module", "demo.wsgi:application", "--chdir", "/src/demo"]

# variant 2
# to try this variant, commend ENTRYPOINT and CMD above, and uncomment following line
# CMD uwsgi --socket 0.0.0.0:8080 --module demo.wsgi:application --chdir /src/demo 2>/dev/null
