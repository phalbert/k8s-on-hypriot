FROM arm32v6/python:3.8-alpine

RUN pip3 install --no-cache-dir linode-dynamic-dns

ENV FREQUENCY=15

CMD linode-dynamic-dns -s "$(expr "$FREQUENCY" '*' 60)"