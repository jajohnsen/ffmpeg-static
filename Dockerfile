FROM ubuntu:jammy

# Basic packages needed to download dependencies and unpack them.
RUN apt-get update && apt-get install -y \
  bzip2 \
  perl \
  tar \
  wget \
  xz-utils \
  && rm -rf /var/lib/apt/lists/*

ENV TZ=Europe/Oslo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install packages necessary for compilation.
RUN apt-get update && apt-get install -y \
  autoconf \
  automake \
  bash \
  build-essential \
  cmake \
  curl \
  frei0r-plugins-dev \
  gawk \
  git \
  libaom-dev \
  libass-dev \
  libdav1d-dev \
  libfontconfig-dev \
  libfreetype6-dev \
  libgnutls28-dev \
  libmp3lame-dev \
  libnuma-dev \
  libopencore-amrnb-dev \
  libopencore-amrwb-dev \
  libpulse-dev \
  libsdl2-dev \
  libsndfile1-dev \
  libspeex-dev \
  libtheora-dev \
  libtool \
  libtwolame-dev \
  libunistring-dev \
  libva-dev \
  libvdpau-dev \
  libvo-amrwbenc-dev \
  libvorbis-dev \
  libwebp-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  libxvidcore-dev \
  libzvbi-dev \
  lsb-release \
  lv2-dev \
  ninja-build \
  pkg-config \
  python3-pip \
  sudo \
  tar \
  texi2html \
  texinfo \
  yasm \
  zlib1g-dev \
  && rm -rf /var/lib/apt/lists/* \
  && pip3 install meson  # We need a newer version for the --prefer_static flag

# Copy the build scripts.
COPY build.sh download.pl env.source fetchurl /ffmpeg-static/

VOLUME /ffmpeg-static
WORKDIR /ffmpeg-static
# CMD /bin/bash
