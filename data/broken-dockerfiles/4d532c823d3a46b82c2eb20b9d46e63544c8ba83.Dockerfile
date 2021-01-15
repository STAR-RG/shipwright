# Install pbsmrtpipe and run a simple dev example
FROM mpkocher/docker-pacbiobase
MAINTAINER Michael Kocher

# Copy the code to container 
COPY ./ /tmp/pbsmrtpipe

# Install
RUN pip install -r /tmp/pbsmrtpipe/REQUIREMENTS.txt && pip install /tmp/pbsmrtpipe

# Run the kick the tires script to run a simple dev job
# RUN bash /tmp/pbsmrtpipe/extras/kick_the_tires.sh
