#!/bin/bash
set -e

cvVersion="$1"
cvPrefix="${1:0:1}"

# Copy required file before checkout
mkdir ~/output
cp -r DEBIAN ~/output/DEBIAN
sed -i "/Version: <cvversion>/c\Version: ${cvVersion}" ~/output/DEBIAN/control
sed -i "/Package: <cvpackage>/c\Package: opencv${cvPrefix}" ~/output/DEBIAN/control

cat ~/output/DEBIAN/control

wget -O opencv.zip https://github.com/opencv/opencv/archive/${cvVersion}.zip
unzip opencv.zip && rm opencv.zip
cd opencv-${cvVersion}

patch -p1 < ../patch/eigen.patch

# Build
mkdir build
cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D WITH_TBB=ON \
      -D WITH_V4L=ON \
      -D WITH_QT=ON \
      -D WITH_OPENGL=ON \
      -D WITH_OPENMP=ON \
      -D WITH_OPENCL=ON \
      -D WITH_IPP=ON \
      -D WITH_CSTRIPES=ON \
      -D BUILD_EXAMPLES=OFF \
      -D BUILD_DOCS=OFF \
      -D BUILD_PERF_TESTS=OFF \
      -D BUILD_TESTS=OFF \
      -D BUILD_JAVA=OFF \
      -D OPENCV_GENERATE_PKGCONFIG=ON ..

make -j$(nproc)
make install DESTDIR=~/output/

# Create .deb
cd ~
cat output/DEBIAN/control
dpkg-deb -b output/ opencv-$cvVersion.deb
cp opencv-$cvVersion.deb $GITHUB_WORKSPACE
ffsend upload opencv-$cvVersion.deb
