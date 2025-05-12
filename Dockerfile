# 1) Build do FFmpeg completo (com drawtext)
FROM jrottenberg/ffmpeg:5.1-alpine AS ffmpeg

# 2) Imagem n8n oficial
FROM n8nio/n8n:latest
USER root

# 3) Copia FFmpeg e libs compilados
COPY --from=ffmpeg /usr/local/bin/ffmpeg   /usr/local/bin/ffmpeg
COPY --from=ffmpeg /usr/local/bin/ffprobe  /usr/local/bin/ffprobe
COPY --from=ffmpeg /usr/local/lib          /usr/local/lib

# 4) Garante dependências de runtime, incluindo OpenSSL 1.1
RUN apk add --no-cache \
      imagemagick \
      tesseract-ocr \
      curl \
      wget \
      zip unzip \
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
