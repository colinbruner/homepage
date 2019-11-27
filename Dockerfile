FROM alpine:3.7 as build

ENV HUGO_VERSION 0.59.1
ENV HUGO_BINARY hugo_${HUGO_VERSION}_Linux-64bit.tar.gz

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

COPY nginx/colinbruner.pem /etc/nginx/colinbruner.pem
COPY nginx/colinbruner.key /etc/nginx/colinbruner.key

COPY --from=build /homepage/public /srv/public

COPY nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443
