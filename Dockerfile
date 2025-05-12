# 1) Imagem pré-montada com FFmpeg completo (Alpine + todos os filtros)
FROM jrottenberg/ffmpeg:5.1-alpine AS ffmpeg

# 2) Sua imagem n8n (Alpine)
FROM n8nio/n8n:latest
USER root

# 3) Copia o binário + todas as libs do ffmpeg “pré-montado”
COPY --from=ffmpeg /usr/local/bin/ffmpeg   /usr/local/bin/ffmpeg
COPY --from=ffmpeg /usr/local/bin/ffprobe  /usr/local/bin/ffprobe
COPY --from=ffmpeg /usr/local/lib          /usr/local/lib
COPY --from=ffmpeg /usr/lib                /usr/lib

# 4) Restaura suas ferramentas auxiliares de sempre
RUN apk update && apk add --no-cache \
      imagemagick \
      tesseract-ocr \
      curl \
      wget \
      zip \
      unzip \
      tar \
      jq \
      openssh-client

USER node
