FROM arm32v7/nginx:stable
COPY public /srv/public
COPY nginx/config/prod.conf /etc/nginx/conf.d/default.conf
EXPOSE 80 443
