FROM alpine:latest

RUN apk add --no-cache bind-tools curl

ADD updater.sh /

CMD [ "/updater.sh"]