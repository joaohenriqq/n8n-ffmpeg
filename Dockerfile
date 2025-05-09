FROM n8nio/n8n:latest

USER root

ARG GLIBC_VER="2.35-r1"

# 1) Instala dependências de build, gcompat e glibc
RUN apk update && apk add --no-cache --virtual .build-deps \
      curl \
      binutils \
      zstd \
      gcompat \
    && curl -LfsS https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
         -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -LfsS https://alpine-pkgs.sgerrand.com/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
         -o /tmp/glibc-${GLIBC_VER}.apk \
    && curl -LfsS https://alpine-pkgs.sgerrand.com/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
         -o /tmp/glibc-bin-${GLIBC_VER}.apk \
    && apk add --force-overwrite --no-cache \
         /tmp/glibc-${GLIBC_VER}.apk \
         /tmp/glibc-bin-${GLIBC_VER}.apk \
    && rm /tmp/glibc-*.apk \
    && apk del .build-deps

# 2) Instala ferramentas auxiliares e remove o ffmpeg minimal
RUN apk add --no-cache \
      ca-certificates \
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
    && apk del ffmpeg

# 3) Baixa e extrai o FFmpeg full do BtbN
RUN cd /tmp \
 && curl -fsSL \
      https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz \
      -o ffmpeg.tar.xz \
 && tar -xJf ffmpeg.tar.xz -C /usr/local --strip-components=1 \
 && rm ffmpeg.tar.xz

USER node
