# -*- coding: utf-8 -*-
# vim: ft=Dockerfile

FROM registry.is-docker.mh00p.net/mytime-base:latest as invoiceninja-base-build
LABEL maintainer="vkom <admin@vkom.cc>"


FROM alpine:latest as invoiceninja-frontend
LABEL maintainer="vkom <admin@vkom.cc>"

WORKDIR /srv/invoiceninja
COPY --from=invoiceninja-base-build --chown=root:root /srv/invoiceninja/public .
RUN chmod -R a=rX .

STOPSIGNAL SIGKILL

CMD ["cat", "/dev/stdout"]
