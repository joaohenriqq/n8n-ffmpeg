FROM n8nio/n8n:latest

USER root

# 1) Instala dependências de build e compila o FFmpeg com todos os codecs e plugins
RUN apk add --no-cache --virtual .build-deps \
      build-base yasm pkgconfig git nasm \
      libvpx-dev x264-dev lame-dev libvorbis-dev opus-dev libtheora-dev \
      libass-dev freetype-dev fontconfig-dev \
      ladspa-dev rubberband-dev frei0r-plugins-dev \
    && git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git /tmp/ffmpeg \
    && cd /tmp/ffmpeg \
    && ./configure \
         --prefix=/usr \
         --disable-static \
         --enable-shared \
         --enable-gpl \
         --enable-nonfree \
         --enable-libvpx \
         --enable-libx264 \
         --enable-libmp3lame \
         --enable-libvorbis \
         --enable-libopus \
         --enable-libtheora \
         --enable-libass \
         --enable-libfreetype \
         --enable-libfontconfig \
         --enable-ladspa \
         --enable-librubberband \
         --enable-frei0r \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -rf /tmp/ffmpeg \
    && apk del .build-deps

# 2) Instala ferramentas de runtime e bibliotecas necessárias para o FFmpeg e outros serviços
RUN apk update && apk add --no-cache \
      imagemagick \
      ghostscript \
      tesseract-ocr \
      curl \
      wget \
      zip \
      unzip \
      tar \
      jq \
      openssh-client \
      ladspa \
      frei0r-plugins \
      rubberband-libs \
      libass \
      libvpx \
      x264-libs \
      lame-libs \
      libvorbis \
      opus \
      libtheora \
      libogg \
      fontconfig \
      freetype \
    && ln -s /usr/lib/frei0r-1 /usr/lib/frei0r \
    && rm -rf /var/cache/apk/*

# ─── ADIÇÕES PARA VOCODERS ─────────────────────────────────

# 3) Instala glibc (via sgerrand) para compatibilidade com wheels PyTorch
ENV GLIBC_RELEASE=2.35-r1
RUN apk add --no-cache ca-certificates wget \
 && wget -q -O /etc/apk/keys/sgerrand.rsa.pub \
      https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_RELEASE}/glibc-${GLIBC_RELEASE}.apk" \
 && wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_RELEASE}/glibc-bin-${GLIBC_RELEASE}.apk" \
 && apk add --no-cache glibc-${GLIBC_RELEASE}.apk glibc-bin-${GLIBC_RELEASE}.apk \
 && rm glibc-*.apk :contentReference[oaicite:1]{index=1}

# 4) Cria virtualenv e instala PyTorch, BigVGAN-v2 e WaveNeXt (com numpy e soundfile)
RUN apk add --no-cache \
      python3 \
      python3-dev \
      py3-pip \
      build-base \
      openblas-dev \
      libstdc++ \
      libgcc \
    && python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir \
         torch \
         numpy \
         soundfile \
         git+https://github.com/NVIDIA/BigVGAN.git@main#egg=bigvgan_v2 \
         git+https://github.com/okamototakuya/wavenext.git@main#egg=wavenext \
    && apk del py3-pip build-base \
    && rm -rf /var/cache/apk/* :contentReference[oaicite:2]{index=2}

# 5) Ajusta o PATH para usar o virtualenv nos workflows
ENV PATH="/opt/venv/bin:${PATH}"

# ─────────────────────────────────────────────────────────────

USER node
