#!/bin/bash
set -eux

#export CC="ccache gcc" CXX="ccache g++"
CFLAGS="-Og -fno-omit-frame-pointer -g"
export LDFLAGS="-static-libgcc"

#export PATH=$(pwd)/llvm-mingw-20220323-ucrt-ubuntu-18.04-x86_64/bin/:$PATH
export CROSSCFLAGS="-Oz -fno-omit-frame-pointer -g"
export CROSSDEBUG=pdb

rm -rf wine-tools wine-win64 wine-win32 wine-src wine-staging
mkdir -p wine-tools wine-win64 wine-win32

outdir=wined3d

if [ ! -d wine-src ]; then

git clone --depth=1000 git://source.winehq.org/git/wine.git ./wine-src
sed -i '4321 i         {WINED3DFMT_X8D24_UNORM,                VK_FORMAT_X8_D24_UNORM_PACK32,     },' wine-src/dlls/wined3d/utils.c
#sed -i 's/return D3DERR_SURFACENOTINVIDMEM;//g' wine-src/dlls/ddraw/device.c

if [[ "${1:-}" == "--staging" ]]; then
git clone --depth=1 https://github.com/wine-staging/wine-staging.git ./wine-staging
cd wine-src
git checkout $(../wine-staging/patches/patchinstall.sh --upstream-commit)
cd ..
cd wine-staging
chmod 775 patches/patchinstall.sh
./patches/patchinstall.sh DESTDIR="../wine-src/" --all
cd ..
fi

fi

ccache -z
cd wine-tools
#export CC='clang -target x86_64-pc-windows-gnu' CXX='clang++ -target x86_64-pc-windows-gnu'
if [ ../wine-src/configure -nt Makefile ] ; then
../wine-src/configure --without-x --enable-win64
fi
make -j4 __tooldeps__

#array=( "" "--host=x86_64-w64-mingw32 CC='ccache gcc' CROSSCC='ccache i686-w64-mingw32-gcc'" )
#for host in "${array[@]}" ; do
#echo "$host"

#apt install -y wget unzip
#wget -q https://sdk.lunarg.com/sdk/download/latest/windows/vulkan-runtime-components.zip
#unzip -j vulkan-runtime-components.zip *x64/vulkan-1.dll

COMMONFLAGS="--with-wine-tools=../wine-tools/ --with-vulkan --without-x --disable-kernel32 --disable-tests --without-freetype --disable-win16"
cd ../wine-win64
host=(--host=x86_64-w64-mingw32) # CC="ccache gcc" CROSSCC="ccache x86_64-w64-mingw32-gcc")
if [ ../wine-src/configure -nt Makefile ] ; then
../wine-src/configure "${host[@]}" $COMMONFLAGS --enable-win64
fi
make -j4 -k $(echo dlls/ddraw* dlls/d3d? dlls/dxgi dlls/wined3d/all | sed 's# #/all #g')
ccache -s
mkdir -p ../$outdir/64
cp -v dlls/*/*.{dll,pdb} ../$outdir/64/

cd ../wine-win32
host=(--host=i686-w64-mingw32) # CC="ccache gcc" CROSSCC="ccache i686-w64-mingw32-gcc")
if [ ../wine-src/configure -nt Makefile ] ; then
../wine-src/configure "${host[@]}" $COMMONFLAGS --with-wine64=../wine-win64/
fi
make -j4 -k $(echo dlls/ddraw* dlls/d3d? dlls/dxgi dlls/wined3d/all | sed 's# #/all #g')
mkdir -p ../$outdir/32
cp -v dlls/*/*.{dll,pdb} ../$outdir/32/

#done
