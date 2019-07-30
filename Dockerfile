FROM alpine:latest

ENV TIME_CHECK=30
ENV TIME_UPDATE=600

RUN apk add --no-cache bind-tools curl

ADD updater.sh /

CMD [ "/updater.sh"]