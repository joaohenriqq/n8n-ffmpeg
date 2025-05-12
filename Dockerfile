# 1) Puxa FFmpeg full (inclui drawtext, ladspa, rubberband, frei0r etc.)
FROM jrottenberg/ffmpeg:5.1-alpine AS ffmpeg

# 2) Imagem n8n oficial (Alpine)
FROM n8nio/n8n:latest

USER root

# 3) Copia apenas o binário e as libs custom do FFmpeg
COPY --from=ffmpeg /usr/local/bin/ffmpeg   /usr/local/bin/ffmpeg
COPY --from=ffmpeg /usr/local/bin/ffprobe  /usr/local/bin/ffprobe
COPY --from=ffmpeg /usr/local/lib/*.so*     /usr/local/lib/

# 4) Ajusta o loader para procurar em /usr/local/lib
ENV LD_LIBRARY_PATH=/usr/local/lib

# 5) Restaura suas ferramentas auxiliares de runtime
RUN apk update && apk add --no-cache \
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
      libass

USER node
