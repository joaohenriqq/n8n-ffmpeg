FROM n8nio/n8n:latest

USER root

# 1) Instala glibc no Alpine para compatibilidade com builds glibc-linked
RUN apk update && apk add --no-cache \
      ca-certificates \
      wget \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub \
         https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.36-r0/glibc-2.36-r0.apk \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.36-r0/glibc-bin-2.36-r0.apk \
    && apk add --no-cache glibc-2.36-r0.apk glibc-bin-2.36-r0.apk \
    && rm glibc-2.36-r0.apk glibc-bin-2.36-r0.apk \
    && update-ca-certificates

# 2) Instala suas ferramentas auxiliares e substitui o FFmpeg por um build completo
RUN apk add --no-cache \
      curl \
      xz \
      lame \
      libvpx \
      x264 \
      imagemagick \
      ghostscript \
      tesseract-ocr \
      zip \
      unzip \
      tar \
      jq \
      openssh-client \
    && apk del ffmpeg \
    && cd /tmp \
    && curl -fsSL https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz \
         -o ffmpeg.tar.xz \
    && tar -xJf ffmpeg.tar.xz -C /usr/local --strip-components=1 \
    && rm ffmpeg.tar.xz

USER node
