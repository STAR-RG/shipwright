###
### DO NOT USE THIS IMAGE IN PRODUCTION !!!
### The mercurial package that is downgraded is subject to https://security-tracker.debian.org/tracker/CVE-2017-17458
### This image is meant to be used only as a demonstration of the Aqua Security MicroScanner Orb.
###

FROM circleci/node:chakracore-8.11.1

# Update apt sources and install a known vulnerable package
RUN echo "Removing known GOOD package" && \
sudo apt purge -f mercurial-common && \
sudo apt-get update && \
echo "Installing known BAD package" && \
sudo apt-get install -t oldstable mercurial-common=3.1.2-2+deb8u4 &&\
sudo apt-get install -t oldstable mercurial=3.1.2-2+deb8u4 &&\
echo "Known BAD package installed"

# ensure that the build agent doesn't override the entrypoint
LABEL com.circleci.preserve-entrypoint=true

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/sh"]