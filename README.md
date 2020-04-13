# RaspberryPi4EGLFS
## A modern guide for cross-compiling Qt (with QtWebEngine) for HW accelerated OpenGL with EGLFS on Raspbian

**Tested configuration:**
- Raspberry Pi 4 4GB version;
- Raspbian Buster February 2020 version;
- Qt 5.14.2;
- Host system: Manjaro Kyria 19.0.2.

## Step by step
- Prepare the image:
  - download [raspbian](https://www.raspberrypi.org/downloads/raspbian/);
  - unzip and write to the microSD card.
- Boot up the Raspberry Pi.

#### [on RPI]:
- in *raspi-config* set the GPU memory to at least 256 MB and enable SSH;
- prepare destination folder for cross-compiled Qt:
```
sudo mkdir /opt/qt5
sudo chown `whoami` /opt/qt5
```
- uncomment debian repository in **/etc/apt/sources.list**
- update the system:

```
sudo apt update; sudo apt dist-upgrade -y
```
- install the necessary libraries:
```
sudo apt install -y \
freetds-dev \
gstreamer1.0-omx \
libasound2-dev \
libavcodec-dev \
libcap-dev \
libdbus-1-dev \
libegl1-mesa-dev \
libevent-dev \
libfontconfig1-dev \
libfreetype6-dev \
libgbm-dev \
libgconf2-dev \
libgcrypt20-dev \
libgl1-mesa-dev \
libgles2-mesa-dev \
libglew-dev \
libgnome-keyring-dev \
libgstreamer-plugins-base1.0-dev \
libgstreamer1.0-dev \
libgtk-3-dev \
libicu-dev \
libinput-dev \
libjpeg-dev \
libjsoncpp-dev \
libkrb5-dev \
liblcms2-dev \
libminizip-dev \
libnss3 \
libnss3-dev \
libopus-dev \
libpci-dev \
libperl-dev \
libpng-dev \
libpoppler-cpp-dev \
libprotobuf-dev \
libpulse-dev \
libre2-dev \
libsnappy-dev \
libsqlite3-dev \
libssl-dev \
libts-dev \
libudev-dev \
libvpx-dev \
libvulkan-dev \
libwebp-dev \
libx11-dev \
libx11-xcb-dev \
libxcb-glx0-dev \
libxcb-icccm4-dev \
libxcb-image0-dev \
libxcb-keysyms1-dev \
libxcb-randr0-dev \
libxcb-render-util0-dev \
libxcb-shape0-dev \
libxcb-shm0-dev \
libxcb-sync-dev \
libxcb-xfixes0-dev \
libxcb-xinerama0 \
libxcb-xinerama0-dev \
libxcb-xinput-dev \
libxcb1-dev \
libxext-dev \
libxfixes-dev \
libxi-dev \
libxkbcommon-x11-dev \
libxml2-dev \
libxrender-dev \
libxslt1-dev \
libxss-dev \
libxtst-dev \
libzstd-dev \
mesa-common-dev \
sqlite \
symlinks \
upower \
zstd
```

#### [on HOST]:
- create a working directory:
```
mkdir ~/raspi
```

- set **pi_ip** to your RPi address and prepare sysroot:
```
cd ~/raspi; \
pi_ip=192.168.0.200; \
rsync -avzz pi@${pi_ip}:/lib sysroot; \
rsync -avzz pi@${pi_ip}:/usr/include sysroot/usr; \
rsync -avzz pi@${pi_ip}:/usr/lib sysroot/usr; \
rsync -avzz pi@${pi_ip}:/usr/share/pkgconfig sysroot/usr/share; \
rsync -avzz pi@${pi_ip}:/opt/vc sysroot/opt
```
- fix relative links:
```
wget https://raw.githubusercontent.com/Kukkimonsuta/rpi-buildqt/master/scripts/utils/sysroot-relativelinks.py
chmod +x sysroot-relativelinks.py
./sysroot-relativelinks.py sysroot
```
- install necessary libraries:

For Ubuntu:
```
sudo apt install -y lib32z1 lib32ncurses5 lib32stdc++6 build-essential
sudo apt install -y libgl1-mesa-dev libgles2-mesa-dev mesa-common-dev
sudo apt install -y g++-multilib python pkg-config gperf bison flex re2c cmake ninja-build libnss3 libnss3-dev libjsoncpp-dev libre2-dev
```
For Manjaro:
```
sudo pacman -S pkgconf cmake ninja flex re2c re2 bison jsoncpp nss
```
- create toolchain with [build_toolchain.sh](build_toolchain.sh) script;
- create folder for qt sources:
```
mkdir qt-src
```
- if you need several Qt modules you can edit the script [build_qt_modules.sh](build_qt_modules.sh) and it will download and build them automatically. If you need all Qt libraries then download the sources manually. Then run the configure script:
```
workdir=~/raspi; \
device=linux-rasp-pi4-v3d-g++; \
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
```
- compile Qt:
```
make -j $(nproc); make install
```
- install libraries on RPi:
```
pi_ip=192.168.0.200; \
rsync -avzz qt5pi/* pi@${pi_ip}:/opt/qt5
```
#### [on RPI]:
-  for desktop usage (platform xcb) you need to set the environment variable before starting your app:
```
export LD_LIBRARY_PATH=/opt/qt5/lib
```
- for EGLFS:
  - switch from graphical to console login via raspi-config;
  - add the user to the render group:
 ```
sudo gpasswd -a `whoami` render
 ```
 - start your application in EGLFS mode:
```
-platform eglfs
```
 - for application with QtWebEngine you can also enable GPU rasterization by adding the appropriate parameters to the comand line:
```
--enable-gpu-rasterization
```
