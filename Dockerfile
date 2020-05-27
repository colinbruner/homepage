FROM debian:latest as zola-base
RUN apt-get update && apt-get install -y wget
RUN wget -c https://github.com/getzola/zola/releases/download/v0.10.0/zola-v0.10.0-x86_64-unknown-linux-gnu.tar.gz -O - | tar -xz
RUN mv zola /usr/bin
WORKDIR /site

FROM zola-base as builder
COPY site /site
RUN zola build

#COPY nginx/config/dev.conf /etc/nginx/conf.d/default.conf
#FROM nginx:stable-alpine
FROM arm32v7/nginx:stable
COPY --from=builder /site/public /srv/public
COPY nginx/cert.pem /etc/ssl/certs/cert.pem
COPY nginx/key.pem /etc/ssl/private/key.pem
COPY nginx/config/prod.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
EXPOSE 443
