FROM nginx:stable
COPY nginx/config/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
