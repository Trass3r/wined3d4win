#!/bin/bash
set -eux

rm -rf wine-tools wine-win64 wine-src wine-staging
mkdir wine-tools wine-win64

outdir=wined3d
git clone --depth=1000 git://source.winehq.org/git/wine.git ./wine-src
if [[ "${1:-}" == "--staging" ]]; then
outdir=wined3d-staging
git clone --depth=1 https://github.com/wine-staging/wine-staging.git ./wine-staging
cd wine-src
git checkout $(../wine-staging/patches/patchinstall.sh --upstream-commit)
cd ..
cd wine-staging
chmod 775 patches/patchinstall.sh
./patches/patchinstall.sh DESTDIR="../wine-src/" --all
cd ..
fi

cd wine-tools
../wine-src/configure --without-x --enable-win64
make -j4 __tooldeps__
cd ../wine-win64
../wine-src/configure --without-x --enable-win64 --without-freetype --without-vkd3d --host=x86_64-w64-mingw32 CFLAGS="-O3 -fno-omit-frame-pointer -g -DWINE_NOWINSOCK -DUSE_WIN32_OPENGL -DUSE_WIN32_VULKAN" --with-wine-tools=../wine-tools/ LDFLAGS=" -static-libgcc"
#make -j4 $(echo dlls/ddraw* dlls/d3d* dlls/dxgi dlls/wined3d/all | sed 's# #/all #g')
make -j4 dlls/ddraw/all dlls/ddrawex/all dlls/wined3d/all
mkdir -p ../$outdir
cp -v dlls/*/*.dll ../$outdir
