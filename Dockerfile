FROM alpine:latest

WORKDIR /webssh

COPY . .

EXPOSE 8080

RUN apk update && apk upgrade &&\
    apk add --no-cache tzdata libc6-compat gcompat coreutils openssl curl &&\
    apk add --no-cache bash &&\
    chmod +x start.sh

ENTRYPOINT ["sh", "start.sh"]