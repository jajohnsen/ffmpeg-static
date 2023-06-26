#!/bin/sh

set -e
set -u

jflag=
jval=2
rebuild=0
download_only=0
uname -mpi | grep -qE 'x86|i386|i686' && is_x86=1 || is_x86=0

while getopts 'j:Bd' OPTION
do
  case $OPTION in
  j)
      jflag=1
      jval="$OPTARG"
      ;;
  B)
      rebuild=1
      ;;
  d)
      download_only=1
      ;;
  ?)
      printf "Usage: %s: [-j concurrency_level] (hint: your cores + 20%%) [-B] [-d]\n" $(basename $0) >&2
      exit 2
      ;;
  esac
done
shift $(($OPTIND - 1))

if [ "$jflag" ]
then
  if [ "$jval" ]
  then
    printf "Option -j specified (%d)\n" $jval
  fi
fi

[ "$rebuild" -eq 1 ] && echo "Reconfiguring existing packages..."
[ $is_x86 -ne 1 ] && echo "Not using yasm or nasm on non-x86 platform..."

cd `dirname $0`
ENV_ROOT=`pwd`
. ./env.source

# check operating system
OS=`uname`
platform="unknown"

case $OS in
  'Darwin')
    platform='darwin'
    ;;
  'Linux')
    platform='linux'
    ;;
esac

#if you want a rebuild
#rm -rf "$BUILD_DIR" "$TARGET_DIR"
mkdir -p "$BUILD_DIR" "$TARGET_DIR" "$DOWNLOAD_DIR" "$BIN_DIR"

#download and extract package
download(){
  filename="$1"
  if [ ! -z "$2" ];then
    filename="$2"
  fi
  ../download.pl "$DOWNLOAD_DIR" "$1" "$filename" "$3" "$4"
  #disable uncompress
  REPLACE="$rebuild" CACHE_DIR="$DOWNLOAD_DIR" ../fetchurl "http://cache/$filename"
}

echo "#### FFmpeg static build ####"

#this is our working directory
cd $BUILD_DIR

[ $is_x86 -eq 1 ] && download \
  "yasm-1.3.0.tar.gz" \
  "" \
  "fc9e586751ff789b34b1f21d572d96af" \
  "http://www.tortall.net/projects/yasm/releases/"

[ $is_x86 -eq 1 ] && download \
  "nasm-2.16.01.tar.bz2" \
  "" \
  "27e5def0791f97c53520e4f852aab42d" \
  "https://www.nasm.us/pub/nasm/releasebuilds/2.16.01/"

download \
  "openssl-3.1.1.tar.gz" \
  "openssl-3.1.1.tar.gz" \
  "0e56948c529ae61f5a6120e69721a4be" \
  "https://github.com/openssl/openssl/archive/"

download \
  "v1.2.13.tar.gz" \
  "zlib-1.2.13.tar.gz" \
  "9c7d356c5acaa563555490676ca14d23" \
  "https://github.com/madler/zlib/archive/"

download \
  "x264-stable.tar.gz" \
  "" \
  "nil" \
  "https://code.videolan.org/videolan/x264/-/archive/stable/"

download \
  "x265_3.5.tar.gz" \
  "" \
  "deb5df5cb2ec17bdbae6ac6bbc3b1eef" \
  "https://bitbucket.org/multicoreware/x265_git/downloads/"

echo "Downloading FDK AAC"
download \
  "v2.0.2.tar.gz" \
  "fdk-aac-2.0.2.tar.gz" \
  "b15f56aebd0b4cfe8532b24ccfd8d11e" \
  "https://github.com/mstorsjo/fdk-aac/archive"

# https://github.com/harfbuzz/harfbuzz/archive/refs/tags/7.3.0.tar.gz
download \
  "7.3.0.tar.gz" \
  "harfbuzz-7.3.0.tar.gz" \
  "b1b03e2c808da28367d226aad0ab09f6" \
  "https://github.com/harfbuzz/harfbuzz/archive/refs/tags/"

download \
   "v1.0.13.tar.gz" \
  "fribidi-1.0.13.tar.gz" \
  "7aa67eb9a386be40629f35517dd52acf" \
  "https://github.com/fribidi/fribidi/archive/refs/tags/"

# libass dependency, was horribly behind (1.4.6, current is 7.3.0...)
download \
  "0.17.1.tar.gz" \
  "libass-0.17.1.tar.gz" \
  "nil" \
  "https://github.com/libass/libass/archive/"

download \
  "lame-3.100.tar.gz" \
  "" \
  "83e260acbe4389b54fe08e0bdbf7cddb" \
  "http://downloads.sourceforge.net/project/lame/lame/3.100"

download \
  "opus-1.4.tar.gz" \
  "" \
  "0d89c15268c5c5984f583d7997d2a148" \
  "https://github.com/xiph/opus/releases/download/v1.4"

download \
  "v1.13.0.tar.gz" \
  "vpx-1.13.0.tar.gz" \
  "d5fd45a806a65a57d6635f9e7a98a1b2" \
  "https://github.com/webmproject/libvpx/archive/"

download \
  "soxr-0.1.3-Source.tar.xz" \
  "" \
  "3f16f4dcb35b471682d4321eda6f6c08" \
  "https://sourceforge.net/projects/soxr/files/"

# Might be breaking changes from 0.98b to 1.1?
download \
  "v1.1.1.tar.gz" \
  "vid.stab-1.1.1.tar.gz" \
  "3fb59a96f6e49e2719fd8c551eb3617a" \
  "https://github.com/georgmartius/vid.stab/archive/"

download \
  "release-3.0.4.tar.gz" \
  "zimg-release-3.0.4.tar.gz" \
  "9ef18426caecf049d3078732411a9802" \
  "https://github.com/sekrit-twc/zimg/archive/"

download \
  "v2.5.0.tar.gz" \
  "openjpeg-2.5.0.tar.gz" \
  "5cbb822a1203dd75b85639da4f4ecaab" \
  "https://github.com/uclouvain/openjpeg/archive/"

download \
  "v1.3.0.tar.gz" \
  "libwebp-1.3.0.tar.gz" \
  "2d818a757f2de1a93d5009a69b3c1ff8" \
  "https://github.com/webmproject/libwebp/archive/"

# "https://github.com/xiph/vorbis/archive/refs/tags/v1.3.7.tar.gz"
download \
  "v1.3.7.tar.gz" \
  "vorbis-1.3.7.tar.gz" \
  "689dc495b22c5f08246c00dab35f1dc7" \
  "https://github.com/xiph/vorbis/archive/refs/tags/"

download \
  "v1.3.5.tar.gz" \
  "ogg-1.3.5.tar.gz" \
  "52b33b31dfff09a89ad1bc07248af0bd" \
  "https://github.com/xiph/ogg/archive/"

download \
  "Speex-1.2.1.tar.gz" \
  "Speex-1.2.1.tar.gz" \
  "2872f3c3bf867dbb0b63d06762f4b493" \
  "https://github.com/xiph/speex/archive/"

download \
  "n6.0.tar.gz" \
  "ffmpeg6.0.tar.gz" \
  "586ca7cc091d26fd0a4c26308950ca51" \
  "https://github.com/FFmpeg/FFmpeg/archive"

download \
  "ladspa_sdk_1.17.tgz" \
  "ladspa_sdk_1.17.tgz" \
  "f4a2fb40405d1fc746d10fe0d3536db1" \
  "http://www.ladspa.org/download"

download \
	"v3.7.2.tar.gz" \
	"AviSynthPlus-3.7.2.tar.gz" \
	"cac7ab4e64af4caa8c10aa14e796331f" \
	"https://github.com/AviSynth/AviSynthPlus/archive/refs/tags/"

# https://breakfastquay.com/files/releases/rubberband-3.2.1.tar.bz2"
download \
  "rubberband-3.2.1.tar.bz2" \
  "" \
  "722f5687d5e020874b865d87c41e03e9" \
  "https://breakfastquay.com/files/releases/"

# https://github.com/toots/shine/releases/download/3.1.1/shine-3.1.1.tar.gz
download \
  "shine-3.1.1.tar.gz" \
  "" \
  "74a2429e9b58ed7834bfe25902131faa" \
  "https://github.com/toots/shine/releases/download/3.1.1/"

# https://github.com/google/snappy/archive/refs/tags/1.1.10.tar.gz
download \
  "1.1.10.tar.gz" \
  "snappy-1.1.10.tar.gz" \
  "70153395ebe6d72febe2cf2e40026a44" \
  "https://github.com/google/snappy/archive/refs/tags/"

# https://github.com/silnrsi/graphite/archive/refs/tags/1.3.14.tar.gz
download \
  "1.3.14.tar.gz" \
  "graphite-1.3.14.tar.gz" \
  "a3cb1dc0032a5875e2eaa4ed57cd38b1" \
  "https://github.com/silnrsi/graphite/archive/refs/tags/"

# https://github.com/zeromq/libzmq/releases/download/v4.3.4/zeromq-4.3.4.tar.gz
download \
  "zeromq-4.3.4.tar.gz" \
  "" \
  "c897d4005a3f0b8276b00b7921412379" \
  "https://github.com/zeromq/libzmq/releases/download/v4.3.4/" 

[ $download_only -eq 1 ] && exit 0

TARGET_DIR_SED=$(echo $TARGET_DIR | awk '{gsub(/\//, "\\/"); print}')

if [ $is_x86 -eq 1 ]; then
    echo "*** Building yasm ***"
    cd $BUILD_DIR/yasm*
    [ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
    [ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --bindir=$BIN_DIR
    make -j $jval
    make install
fi

if [ $is_x86 -eq 1 ]; then
    echo "*** Building nasm ***"
    cd $BUILD_DIR/nasm*
    [ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
    [ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --bindir=$BIN_DIR
    make -j $jval
    make install
fi

echo "*** Building OpenSSL ***"
cd $BUILD_DIR/openssl*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "darwin" ]; then
  PATH="$BIN_DIR:$PATH" ./Configure darwin64-x86_64-cc --prefix=$TARGET_DIR
elif [ "$platform" = "linux" ]; then
  PATH="$BIN_DIR:$PATH" ./config CFLAGS="-fPIC" --prefix=$TARGET_DIR
fi
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "*** Building zlib ***"
cd $BUILD_DIR/zlib*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "linux" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR
elif [ "$platform" = "darwin" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR
fi
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "*** Building x264 ***"
cd $BUILD_DIR/x264*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --enable-static --disable-shared --disable-opencl --enable-pic
PATH="$BIN_DIR:$PATH" make -j $jval
make install

# We need to have git installed on the system for cmake to pick up the version of X265
# and create the x265.pc (pkg-config).
# We use the supplied multilib build script with a patch to set the correct install prefix,
# this makes 8-, 10 and 12bit x265 options available in FFmpeg (run `ffmpeg -h
# encoder=libx265` to verify)
# TODO: Patch fails on rerun because it has already been applied.
echo "*** Building x265 ***"
cd $BUILD_DIR/x265*
cd build/linux
[ $rebuild -eq 1 ] && find . -mindepth 1 ! -name 'make-Makefiles.bash' -and ! -name 'multilib.sh' -exec rm -r {} +
patch -p1 < /patch-files/multilib-install-prefix.patch 
PATH="$BIN_DIR:$PATH" INSTALL_PREFIX="$TARGET_DIR" MAKEFLAGS="-j ${jval}" ./multilib.sh
cd 8bit/
sed -i 's/-lgcc_s/-lgcc_eh/g' x265.pc
make install

echo "*** Building fdk-aac ***"
cd $BUILD_DIR/fdk-aac*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
autoreconf -fiv
[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building Graphite2 ***"
cd $BUILD_DIR/graphite-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
mkdir -p build && cd build/
PATH="$BIN_DIR:$PATH" CFLAGS="-I$TARGET_DIR/include" \
  cmake ../ -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DBUILD_SHARED_LIBS="OFF"
make -j $jval
make install

# harfbuzz har moved to use Meson to build
echo "*** Building harfbuzz ***"
cd $BUILD_DIR/harfbuzz-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
meson build 
meson configure --prefix=$TARGET_DIR --prefer-static -Dgraphite2="enabled" ./build
cd ./build
meson install

echo "*** Building fribidi ***"
cd $BUILD_DIR/fribidi-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
meson build -Ddocs=false
meson configure --prefix=$TARGET_DIR --prefer-static ./build
cd ./build
meson install

echo "*** Building libass ***"
cd $BUILD_DIR/libass-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building mp3lame ***"
cd $BUILD_DIR/lame*
# The lame build script does not recognize aarch64, so need to set it manually
uname -a | grep -q 'aarch64' && lame_build_target="--build=arm-linux" || lame_build_target=''
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --enable-nasm --disable-shared $lame_build_target
make
make install

echo "*** Building opus ***"
cd $BUILD_DIR/opus*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --disable-shared
make
make install

echo "*** Building libvpx ***"
cd $BUILD_DIR/libvpx*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --disable-examples --disable-unit-tests --enable-pic
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "*** Building libsoxr ***"
cd $BUILD_DIR/soxr-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DBUILD_SHARED_LIBS:bool=off -DWITH_OPENMP:bool=off -DBUILD_TESTS:bool=off
make -j $jval
make install

echo "*** Building libvidstab ***"
cd $BUILD_DIR/vid.stab-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "linux" ]; then
  sed -i "s/vidstab SHARED/vidstab STATIC/" ./CMakeLists.txt
elif [ "$platform" = "darwin" ]; then
  sed -i "" "s/vidstab SHARED/vidstab STATIC/" ./CMakeLists.txt
fi
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DBUILD_SHARED_LIBS=OFF
make -j $jval
make install

echo "*** Building openjpeg ***"
cd $BUILD_DIR/openjpeg-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DBUILD_SHARED_LIBS:bool=off
make -j $jval
make install

echo "*** Building zimg ***"
cd $BUILD_DIR/zimg-release-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --enable-static  --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building libwebp ***"
cd $BUILD_DIR/libwebp*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building libvorbis ***"
cd $BUILD_DIR/vorbis*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building libogg ***"
cd $BUILD_DIR/ogg*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building libspeex ***"
cd $BUILD_DIR/speex*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building ladspa ***"
cd $BUILD_DIR/ladspa*
cp src/ladspa.h $TARGET_DIR/include/

echo "*** Building AviSynthPlus ***"
cd $BUILD_DIR/AviSynthPlus-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
mkdir -p avisynth-build && cd avisynth-build
PATH="$BIN_DIR:$PATH" cmake ../ -DHEADERS_ONLY:bool=on -DCMAKE_INSTALL_PREFIX="$TARGET_DIR"
make VersionGen install

echo "*** Building Rubber Band ***"
cd $BUILD_DIR/rubberband-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
meson setup build -Ddefault_library=static 
meson configure --prefix=$TARGET_DIR --prefer-static ./build
cd ./build
meson install

echo "*** Building Shine ***"
cd $BUILD_DIR/shine-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && \
  ./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building Snappy ***"
cd $BUILD_DIR/snappy-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DSNAPPY_BUILD_TESTS="OFF" -DSNAPPY_BUILD_BENCHMARKS="OFF" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR"
make -j $jval
make install

echo "*** Building ZeroMQ ***"
[ $rebuild -eq 0 -a -f Makefile ] && make distclean || true
cd $BUILD_DIR/zeromq-*
./configure --prefix=$TARGET_DIR --enable-static
make -j $jval
make install

# FFMpeg
echo "*** Building FFmpeg ***"
cd $BUILD_DIR/FFmpeg*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
echo "TARGET_DIR is set to be ${TARGET_DIR}"

if [ "$platform" = "linux" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" \
     ./configure \
    --prefix="$TARGET_DIR" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$TARGET_DIR/include" \
    --extra-ldflags="-L$TARGET_DIR/lib -L$TARGET_DIR/lib64" \
    --extra-libs="-lpthread -lm -lz" \
    --extra-ldexeflags="-static" \
    --bindir="$BIN_DIR" \
    --enable-pic \
    --enable-ffplay \
    --enable-fontconfig \
    --enable-frei0r \
    --enable-gpl \
    --enable-version3 \
    --enable-libass \
    --enable-libfribidi \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libopenjpeg \
    --enable-libopus \
    --enable-libsoxr \
    --enable-libspeex \
    --enable-libtheora \
    --enable-libvidstab \
    --enable-libvo-amrwbenc \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxvid \
    --enable-libzimg \
    --enable-nonfree \
    --enable-openssl \
    --enable-ladspa \
    --enable-libzmq \
    --enable-avisynth \
    --enable-libbluray \
    --enable-libfontconfig \
    --enable-libgme \
    --enable-libgsm \
    --enable-libmodplug \
    --enable-libmysofa \
    --enable-librubberband \
    --enable-libshine \
    --enable-libsnappy \
    --enable-libtwolame \
    --enable-libzvbi
elif [ "$platform" = "darwin" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" \
  PKG_CONFIG_PATH="${TARGET_DIR}/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:/usr/local/Cellar/openssl/1.0.2o_1/lib/pkgconfig" ./configure \
    --cc=/usr/bin/clang \
    --prefix="$TARGET_DIR" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$TARGET_DIR/include" \
    --extra-ldflags="-L$TARGET_DIR/lib" \
    --extra-ldexeflags="-Bstatic" \
    --bindir="$BIN_DIR" \
    --enable-pic \
    --enable-ffplay \
    --enable-fontconfig \
    --enable-frei0r \
    --enable-gpl \
    --enable-version3 \
    --enable-libass \
    --enable-libfribidi \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libopenjpeg \
    --enable-libopus \
    --enable-libsoxr \
    --enable-libspeex \
    --enable-libtheora \
    --enable-libvidstab \
    --enable-libvo-amrwbenc \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxvid \
    --enable-libzimg \
    --enable-nonfree \
    --enable-openssl \
    --enable-ladspa \
    --enable-libzmq \
    --enable-avisynth \
    --enable-libbluray \
    --enable-libfontconfig \
    --enable-libgme \
    --enable-libgsm \
    --enable-libmodplug \
    --enable-libmysofa \
    --enable-librubberband \
    --enable-libshine \
    --enable-libsnappy \
    --enable-libtwolame \
    --enable-libzvbi
fi

PATH="$BIN_DIR:$PATH" make -j $jval
make install
make distclean
hash -r
