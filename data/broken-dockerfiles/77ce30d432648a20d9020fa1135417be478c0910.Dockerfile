# Use the latest python image from DockerHub (3.x)
FROM python:3

# Install postgresql dev headers and the lxml parser library
RUN apt-get -y update \
    && apt-get install -y libpq-dev python3-lxml

# Copy local files into the palantiri directory
COPY . /palantiri/

# Install the dependencies and the palantiri package using setup.py,
# copy the search script to the root directory and delete /palantiri
# to keep the image slim
RUN pip install /palantiri --process-dependency-links --allow-all-external \
    && cp /palantiri/search.py . \
    && rm -rf /palantiri

# Run crawler on Backpage.com
CMD ["/usr/local/bin/python", "search.py", "-b", "Roommates"]
