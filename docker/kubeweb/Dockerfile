FROM alpine as clone

WORKDIR /app

RUN apk add --no-cache git

RUN git clone https://codeberg.org/hjacobs/kube-web-view.git . && \
    git checkout master

# fake package to make Poetry happy (we will install the actual contents in the later stage)
RUN mkdir /kube_web && touch /kube_web/__init__.py && touch /README.md

FROM arm32v6/python:3.8-alpine

RUN apk add --no-cache gcc musl-dev libffi-dev openssl-dev

ARG VERSION=dev

RUN pip3 install poetry

WORKDIR /kube_web

COPY --from=clone /app/kube_web /kube_web

RUN touch /kube_web/__init__.py && touch /README.md

RUN poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-dev --no-ansi

# replace build version in package and
# add build version to static asset links to break browser cache
# see also "version" in Makefile
RUN sed -i "s/^__version__ = .*/__version__ = \"${VERSION}\"/" /kube_web/__init__.py && \
    sed -i "s/v=[0-9A-Za-z._-]*/v=${VERSION}/g" /kube_web/templates/base.html

ENTRYPOINT ["/usr/local/bin/python", "-m", "kube_web"]