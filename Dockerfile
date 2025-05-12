# Stage 1: usa FFmpeg full (inclui drawtext, frei0r, ladspa, rubberband etc.)
FROM jrottenberg/ffmpeg:6.0-alpine as ffmpeg

# Stage 2: imagem oficial do n8n (Alpine)
FROM n8nio/n8n:latest

USER root

# Copia binários e libs do FFmpeg
COPY --from=ffmpeg /usr/local/bin/ffmpeg  /usr/local/bin/ffmpeg
COPY --from=ffmpeg /usr/local/bin/ffprobe /usr/local/bin/ffprobe
COPY --from=ffmpeg /usr/local/lib/        /usr/local/lib/

# Garante que o sistema reconheça as libs do FFmpeg
ENV LD_LIBRARY_PATH="/usr/local/lib"

# Instala ferramentas auxiliares de runtime
RUN apk add --no-cache \
    imagemagick \
    tesseract-ocr \
    ghostscript \
    curl \
    wget \
    zip unzip \
    tar \
    jq \
    openssh-client \
    fontconfig \
    freetype \
    libass

USER node
