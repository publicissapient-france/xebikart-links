FROM alpine:3.10.2

ENV HUGO_VERSION 0.57.2
ENV HUGO_ARCHIVE_URL https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz

# Can't just ADD <url> because of https://github.com/moby/moby/issues/12361
RUN apk add -u curl \
    && curl -L -o /tmp/hugo.tar.gz ${HUGO_ARCHIVE_URL} \
    && mkdir /tmp/hugo \
    && tar -xvf /tmp/hugo.tar.gz -C /tmp/hugo \
    && mv /tmp/hugo/hugo /bin/hugo \
    && chmod +x /bin/hugo \
    && rm -rf /tmp/hugo* /var/cache/apk

WORKDIR /sources

COPY config.toml .
# Reminder: copy-ing a directory copies the content, so we have to make the
# target path explicit
COPY themes ./themes
COPY data   ./data
COPY public ./public

RUN hugo

FROM nginx:1.17.3-alpine

COPY --from=0 /sources/public /usr/share/nginx/html
