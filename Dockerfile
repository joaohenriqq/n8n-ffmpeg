FROM n8nio/n8n:1.86.1

USER root

RUN apk add --no-cache \
  ffmpeg \
  lame \
  libvpx \
  x264 \
  imagemagick \
  ghostscript \
  tesseract-ocr \
  curl \
  wget \
  zip \
  unzip \
  tar \
  jq \
  openssh-client

USER node
