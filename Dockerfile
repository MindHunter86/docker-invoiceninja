# -*- coding: utf-8 -*-
# vim: ft=Dockerfile


FROM node:lts-alpine as invoiceninja-base-build
LABEL maintainer="vkom <admin@vkom.cc>"

ARG TARBALL_VERSION="v5.2.12"
ADD https://github.com/invoiceninja/invoiceninja/tarball/${TARBALL_VERSION} /tmp/invoiceninja_${TARBALL_VERSION}.tgz

WORKDIR /srv/invoiceninja

RUN tar --strip-components=1 -xf /tmp/invoiceninja_${TARBALL_VERSION}.tgz -C . \
	&& mkdir -p public/logo storage \
	&& rm -rf docs tests .env.example

RUN --mount=target=node_modules,type=cache \
	npm install --production \
	&& npm run production


FROM php:7.4-fpm-alpine3.13 as invoiceninja-backend
LABEL maintainer="vkom <admin@vkom.cc>"

WORKDIR /srv/invoiceninja

RUN apk add --no-cache mysql-client git chromium ttf-freefont
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin
RUN install-php-extensions \
	bcmath \
	exif \
	gd \
	gmp \
	mysqli \
	opcache \
	pdo_mysql \
	zip \
	@composer \
	&& rm /usr/local/bin/install-php-extensions

RUN addgroup --system w3ninja \
	&& adduser --system --disabled-password --home /srv/invoiceninja --shell /sbin/nologin --ingroup w3ninja w3ninja
COPY --chown=w3ninja:w3ninja /srv/invoiceninja .
RUN rm -rf public storage

USER w3ninja:w3ninja

ENV IS_DOCKER true
RUN /usr/local/bin/composer install --no-dev --quiet

RUN apk add --no-cache tzdata \
	&& ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime \
	&& echo 'Europe/Moscow' > /etc/timezone

CMD ["php-fpm"]


FROM alpine:latest as invoiceninja-frontend
LABEL maintainer="vkom <admin@vkom.cc>"

WORKDIR /srv/invoiceninja
COPY --chown=root:root /srv/invoiceninja/public .
RUN chmod -R a=rX .

STOPSIGNAL SIGKILL

CMD ["cat", "/dev/stdout"]












# mytime deploy Dockerfile - base
FROM node:12-alpine
LABEL maintainer="vkom <admin@mh00p.net>"

ARG MYTIME_RELEASE_URL=https://example.com

# prepare build directory:
RUN mkdir -pm0700 /usr/src/mytime

WORKDIR /usr/src/mytime

# download and unpack mytime release:
RUN apk add --no-cache curl \
	&& curl -LSs ${MYTIME_RELEASE_URL} | tar zxvC .

# install python for as npm plugin dependence:
RUN apk add --no-cache build-base python

# npm install:
RUN npm i

# remove package metadata files for production:
RUN rm -vf package.json \
	&& rm -vf package-lock.json

# fix permissions:
RUN apk add --no-cache findutils \
	&& find . -type f -exec chmod 0440 {} \; \
	&& find . -type d -exec chmod 2150 {} \; \
	&& apk del findutils

# prepare additional directories:
RUN mkdir -pm0170 cache

# debug:
RUN ls -la /usr/src/mytime
