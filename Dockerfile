#FROM nginx:stable
FROM arm32v7/nginx:stable
COPY workspace/public /srv/public
COPY nginx/config/prod.conf /etc/nginx/conf.d/default.conf
#COPY nginx/config/dev.conf /etc/nginx/conf.d/default.conf
EXPOSE 80 443
