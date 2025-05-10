FROM n8nio/n8n:latest

USER root

# 1) Instala glibc-compat para rodar o build glibc-linked do BtbN
RUN apk update && apk upgrade && \
    apk add --no-cache ca-certificates wget curl xz tar && \
    # importa a chave e instala o glibc-compat
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.36-r0/glibc-2.36-r0.apk && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.36-r0/glibc-bin-2.36-r0.apk && \
    apk add --no-cache glibc-2.36-r0.apk glibc-bin-2.36-r0.apk && \
    rm glibc-2.36-r0.apk glibc-bin-2.36-r0.apk && \
    update-ca-certificates

# 2) Remove o ffmpeg “mínimo” instalado via apk
RUN apk del ffmpeg

# 3) Baixa e instala o FFmpeg static build mais recente do BtbN (linux64-gpl)
RUN cd /tmp && \
    curl -fsSL https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz \
      -o ffmpeg.tar.xz && \
    tar -xJf ffmpeg.tar.xz -C /usr/local --strip-components=1 && \
    rm ffmpeg.tar.xz

# 4) (Re)instala todas as suas ferramentas auxiliares sem alterar o resto
RUN apk update && apk upgrade && \
    apk add --no-cache \
      lame libvpx x264 \
      imagemagick ghostscript tesseract-ocr \
      curl wget zip unzip tar jq openssh-client && \
    rm -rf /var/cache/apk/*

USER node
