FROM alpine:3.20

WORKDIR /app

RUN apk update && apk upgrade && \
    apk add --no-cache tzdata libc6-compat gcompat coreutils openssl curl bash

RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        curl -L -o webssh https://github.com/eooce/webssh/releases/download/webssh/webssh-amd64; \
    elif [ "$ARCH" = "aarch64" ]; then \
        curl -L -o webssh https://github.com/eooce/webssh/releases/download/webssh/webssh-arm64; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    chmod +x webssh

EXPOSE 8888/tcp

CMD ["./webssh"]
