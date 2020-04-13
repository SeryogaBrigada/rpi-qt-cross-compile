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
binutils_v=binutils-2.31.1
gcc_v=gcc-8.3.0

export WORKSPACE_ROOT=~/raspi
export PREFIX=${WORKSPACE_ROOT}/toolchain
export TARGET=arm-linux-gnueabihf
export SYSROOT=${WORKSPACE_ROOT}/sysroot
export PATH=${PREFIX}/bin:$PATH
mkdir -p ${PREFIX}
cd ${WORKSPACE_ROOT}

mkdir -p tmp/binutils-build
mkdir -p tmp/gcc-build
cd tmp

wget https://ftp-gnu-org.ip-connect.vn.ua/binutils/${binutils_v}.tar.gz
wget https://ftp-gnu-org.ip-connect.vn.ua/gcc/${gcc_v}/${gcc_v}.tar.gz

tar -xf ${binutils_v}.tar.gz
tar -xf ${gcc_v}.tar.gz

cd binutils-build
../${binutils_v}/configure --target=${TARGET} --prefix=${PREFIX} --with-arch=armv6 --with-fpu=vfp --with-float=hard --disable-multilib
make -j $(nproc)
make install

cd ${gcc_v}
bash contrib/download_prerequisites

cd ../gcc-build
../${gcc_v}/configure --prefix=${PREFIX} --target=${TARGET} --with-sysroot=${SYSROOT} --enable-languages=c,c++ --disable-multilib --enable-multiarch --with-arch=armv6 --with-fpu=vfp --with-float=hard
make -j $(nproc)
make install

cd ../..
rm -rf tmp

