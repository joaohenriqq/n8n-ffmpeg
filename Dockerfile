FROM n8nio/n8n:latest
USER root

# 1) Habilita o repositório edge/testing para ter a versão completa do ffmpeg
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# 2) Atualiza pacotes e instala FFmpeg, codecs, extras, Rubber Band e ferramentas auxiliares
RUN apk update && \
    apk add --no-cache \
      ffmpeg \
      lame \
      libvpx \
      x264-libs \
      imagemagick \
      ghostscript \
      tesseract-ocr \
      fontconfig \
      freetype \
      ladspa-sdk \
      frei0r-plugins \
      rubberband \
      rubberband-libs \
      rubberband-dev \
      curl \
      wget \
      zip \
      unzip \
      tar \
      jq \
      openssh-client && \
    rm -rf /var/cache/apk/*

USER node
