FROM n8nio/n8n:latest

USER root

RUN apk update && apk upgrade && apk add --no-cache \
    ca-certificates \
    curl \
    xz \
    lame \
    libvpx \
    x264-libs \
    imagemagick \
    ghostscript \
    tesseract-ocr \
    zip \
    unzip \
    tar \
    jq \
    openssh-client && \
  update-ca-certificates && \
  apk del ffmpeg && \
  cd /tmp && \
  curl -fsSL https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz -o ffmpeg.tar.xz && \
  tar -xJf ffmpeg.tar.xz -C /usr/local --strip-components=1 && \
  rm ffmpeg.tar.xz

USER node
