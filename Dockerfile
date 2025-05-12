
# 1) Build do FFmpeg completo (com todos os filtros, incluindo drawtext)
FROM jrottenberg/ffmpeg:5.1-alpine AS ffmpeg

# 2) Imagem n8n oficial
FROM n8nio/n8n:latest

USER root

# 3) Copia o FFmpeg compilado com drawtext e todas as libs
COPY --from=ffmpeg /usr/local/bin/ffmpeg   /usr/local/bin/ffmpeg
COPY --from=ffmpeg /usr/local/bin/ffprobe  /usr/local/bin/ffprobe
COPY --from=ffmpeg /usr/local/lib          /usr/local/lib

# 4) Garante que as dependências de runtime da sua stack n8n continuem instaladas
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
      libass

USER node
