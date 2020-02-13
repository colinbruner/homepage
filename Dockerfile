FROM alpine:3.7 as build

ENV HUGO_VERSION 0.63.2
ENV HUGO_BINARY hugo_extended_${HUGO_VERSION}_Linux-ARM.tar.gz

# Install Hugo
RUN set -x && \
  apk add --update wget ca-certificates && \
  wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} && \
  tar xzf ${HUGO_BINARY} && \
  rm -r ${HUGO_BINARY} && \
  mv hugo /usr/bin && \
  apk del wget ca-certificates && \
  rm /var/cache/apk/*

COPY ./homepage /homepage

WORKDIR /homepage

# Build site
RUN /usr/bin/hugo

FROM nginx:alpine

COPY nginx/cert.pem /etc/ssl/certs/cert.pem
COPY nginx/key.pem /etc/ssl/private/key.pem

COPY --from=build /homepage/public /srv/public

COPY nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443
