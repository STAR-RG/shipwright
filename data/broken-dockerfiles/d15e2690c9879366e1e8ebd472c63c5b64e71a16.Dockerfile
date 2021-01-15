FROM node:4-onbuild

# Adds <!SERVER-URL!> as address, so that it can be substituted during startup
RUN npm install && npm run buildprod -- --server '<!SERVER-URL!>'
EXPOSE 8080

# Default server api address value
CMD ["http://localhost:4321/api/"]
ENTRYPOINT ["/usr/src/app/docker_start_xr_web_app.sh"]
