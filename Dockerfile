# Base: imagem oficial do n8n (Alpine Linux)
FROM n8nio/n8n:latest

USER root

# Instala FFmpeg e ferramentas auxiliares
RUN apk update && apk add --no-cache \
      ffmpeg \
      imagemagick \
      tesseract-ocr \
      curl \
      wget \
      zip \
      unzip \
      tar \
      jq \
      openssh-client \
      fontconfig \
      freetype \
      libass

USER node
