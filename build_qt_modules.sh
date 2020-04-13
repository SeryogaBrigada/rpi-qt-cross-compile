# MIT License

# Copyright (c) 2020 Sergey Kovalenko

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#!/bin/bash
workdir=$(pwd)
qt_major=5.14
qt_ver=5.14.2
device=linux-rasp-pi4-v3d-g++

function buildQtModule() {
    cd $1
    ${workdir}/qt5/bin/qmake
    make -j $(nproc)
    make install
}

function downloadAndExtract() {
    [[ ! -f $1.tar.xz ]] && wget https://download.qt.io/official_releases/qt/${qt_major}/${qt_ver}/submodules/$1.tar.xz
    [[ -d $1 ]] && rm -rf $1;
    tar -xf $1.tar.xz
}

[[ ! -d qt-src ]] && mkdir qt-src;
cd qt-src

downloadAndExtract qtxmlpatterns-everywhere-src-${qt_ver}
downloadAndExtract qtwebengine-everywhere-src-${qt_ver}
downloadAndExtract qtquickcontrols2-everywhere-src-${qt_ver}
downloadAndExtract qtquickcontrols-everywhere-src-${qt_ver}
downloadAndExtract qtmultimedia-everywhere-src-${qt_ver}
downloadAndExtract qtgraphicaleffects-everywhere-src-${qt_ver}
downloadAndExtract qtdeclarative-everywhere-src-${qt_ver}
downloadAndExtract qtbase-everywhere-src-${qt_ver}

cd qtbase-everywhere-src-${qt_ver}
./configure -release -opensource -confirm-license -v \
-device ${device} \
-device-option CROSS_COMPILE=${workdir}/toolchain/bin/arm-linux-gnueabihf- \
-prefix /opt/qt5 \
-extprefix ${workdir}/qt5pi \
-hostprefix ${workdir}/qt5 \
-sysroot ${workdir}/sysroot \
-opengl es2 \
-eglfs \
-xcb \
-no-pch \
-nomake examples \
-nomake tests \
-no-use-gold-linker

make -j $(nproc)
make install

buildQtModule ../qtdeclarative-everywhere-src-${qt_ver}
buildQtModule ../qtgraphicaleffects-everywhere-src-${qt_ver}
buildQtModule ../qtmultimedia-everywhere-src-${qt_ver}
buildQtModule ../qtquickcontrols2-everywhere-src-${qt_ver}
buildQtModule ../qtquickcontrols-everywhere-src-${qt_ver}
buildQtModule ../qtxmlpatterns-everywhere-src-${qt_ver}

cd ../qtwebengine-everywhere-src-${qt_ver}
${workdir}/qt5/bin/qmake
make
make install

