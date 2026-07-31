FROM nginx:latest
RUN rm -rf /usr/share/nginx/html/*
COPY infrastructure-modules/src/index.html /usr/share/nginx/html/index.html
RUN chmod 644 /usr/share/nginx/html/index.html
EXPOSE 80