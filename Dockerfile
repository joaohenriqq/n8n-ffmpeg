FROM n8nio/n8n:latest
USER root

# Enable edge/testing repository for full FFmpeg build and RubberBand
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Update package index and install FFmpeg, codecs, filters, RubberBand and utilities
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
      curl \
      wget \
      zip \
      unzip \
      tar \
      jq \
      openssh-client && \
    rm -rf /var/cache/apk/*

USER node
