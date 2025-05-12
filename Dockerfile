# 1) Build do FFmpeg completo (com drawtext)
FROM jrottenberg/ffmpeg:5.1-alpine AS ffmpeg

# 2) Imagem n8n oficial (Alpine)
FROM n8nio/n8n:latest

USER root

# 3) Copia FFmpeg + libs compilados
COPY --from=ffmpeg /usr/local/bin/ffmpeg   /usr/local/bin/ffmpeg
COPY --from=ffmpeg /usr/local/bin/ffprobe  /usr/local/bin/ffprobe
COPY --from=ffmpeg /usr/local/lib          /usr/local/lib

# 4) Habilita community repo e instala runtime via apk
RUN sed -i 's/^#\s*\(.*community\)$/\1/' /etc/apk/repositories \
 && apk update \
 && apk add --no-cache \
      imagemagick \
      tesseract-ocr \
      curl \
      wget \
      zip \
      unzip \
      tar \
      jq \
      openssh-client \
      frei0r-plugins \
      ladspa \
      rubberband \
      fontconfig \
      freetype \
      libass \
      libssl1.1

USER node
