FROM n8nio/n8n:1.89.2

USER root

RUN apk update && apk upgrade && apk add --no-cache \
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
