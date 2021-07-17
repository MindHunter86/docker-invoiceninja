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
