FROM n8nio/n8n:latest
USER root

# Habilita edge/testing para ter a versão completa do FFmpeg e RubberBand
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Atualiza índices e instala FFmpeg com codecs, filtros, RubberBand e ferramentas auxiliares
RUN apk update && \
    apk add --no-cache \
      ffmpeg \
      imagemagick \
      ghostscript \
      tesseract-ocr \
      fontconfig \
      freetype \
      ladspa \
      frei0r-plugins \
      rubberband \
      curl \
      wget \
      zip \
      unzip \
      tar \
      jq \
      openssh-client && \
    rm -rf /var/cache/apk/*

USER node
