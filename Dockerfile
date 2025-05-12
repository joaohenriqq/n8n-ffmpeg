# 1) Build FFmpeg completo com drawtext
FROM jrottenberg/ffmpeg:5.1-alpine AS ffmpeg

# 2) Imagem n8n baseada em Alpine
FROM n8nio/n8n:latest
USER root

# 3) Copia o FFmpeg e libs compilados
COPY --from=ffmpeg /usr/local/bin/ffmpeg   /usr/local/bin/ffmpeg
COPY --from=ffmpeg /usr/local/bin/ffprobe  /usr/local/bin/ffprobe
COPY --from=ffmpeg /usr/local/lib          /usr/local/lib

# 4) Instala pacotes de runtime via apk
RUN apk update && apk add --no-cache \
      imagemagick \       # manipulação de imagens :contentReference[oaicite:4]{index=4}
      tesseract-ocr \      # OCR :contentReference[oaicite:5]{index=5}
      curl \               # requisições HTTP :contentReference[oaicite:6]{index=6}
      wget \               # downloads :contentReference[oaicite:7]{index=7}
      zip unzip \          # compressão :contentReference[oaicite:8]{index=8}
      tar \                # arquivamento :contentReference[oaicite:9]{index=9}
      jq \                 # JSON CLI :contentReference[oaicite:10]{index=10}
      openssh-client \     # SSH :contentReference[oaicite:11]{index=11}
      frei0r-plugins \     # plugins FFmpeg :contentReference[oaicite:12]{index=12}
      ladspa \             # DSP plugins :contentReference[oaicite:13]{index=13}
      rubberband \         # pitch/time stretch :contentReference[oaicite:14]{index=14}
      fontconfig \         # gerenciamento de fontes :contentReference[oaicite:15]{index=15}
      freetype \           # renderização de texto :contentReference[oaicite:16]{index=16}
      libass \             # legendas ASS :contentReference[oaicite:17]{index=17}
      libssl1.1            # compat OpenSSL 1.1
USER node
