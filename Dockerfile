FROM nginx:latest
RUN rm -rf /usr/share/nginx/html/*
COPY src/index.html /usr/share/nginx/html/index.html
EXPOSE 80