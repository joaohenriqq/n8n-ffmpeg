# 1) Build do FFmpeg completo (com drawtext)
FROM jrottenberg/ffmpeg:5.1-alpine AS ffmpeg

# 2) Imagem n8n Alpine
FROM n8nio/n8n:alpine

USER root

# 3) Copia FFmpeg + libs compilados
COPY --from=ffmpeg /usr/local/bin/ffmpeg   /usr/local/bin/ffmpeg
COPY --from=ffmpeg /usr/local/bin/ffprobe  /usr/local/bin/ffprobe
COPY --from=ffmpeg /usr/local/lib          /usr/local/lib

# 4) Habilita community repo e instala runtime (incluindo openssl1.1)
RUN echo ">> Adicionando community repo para OpenSSL 1.1" \
  && echo "https://dl-cdn.alpinelinux.org/alpine/$(cut -d. -f1,2 /etc/alpine-release)/community" \
     >> /etc/apk/repositories \
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
      openssl1.1

USER node
