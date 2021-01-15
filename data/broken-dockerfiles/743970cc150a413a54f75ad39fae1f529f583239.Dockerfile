FROM arm32v7/nginx:1.12
MAINTAINER Tuuu <song@secbox.cn>

COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
