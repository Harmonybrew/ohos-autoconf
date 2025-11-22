#!/bin/sh
set -e

# 当前工作目录。拼接绝对路径的时候需要用到这个值。
WORKDIR=$(pwd)

# 如果存在旧的目录和文件，就清理掉
rm -rf *.tar.gz \
    autoconf-2.72 \
    autoconf-2.72-ohos-arm64 \
    install

# 准备源码
curl -L -O http://mirrors.ustc.edu.cn/gnu/autoconf/autoconf-2.72.tar.gz
tar -zxf autoconf-2.72.tar.gz
cd autoconf-2.72

# 构建 autoconf。这是个纯脚本软件，不需要编译器，有 make、perl、m4 就够了。
export M4=m4
./configure --prefix=/opt/autoconf-2.72-ohos-arm64 --host=aarch64-linux
make -j$(nproc)
make DESTDIR=${WORKDIR}/install install
cd ..

# 不要整棵目录树，只要最内层目录
cp -r install/opt/autoconf-2.72-ohos-arm64 ./

# 履行开源义务，将 license 随制品一起发布
cp autoconf-2.72/COPYING autoconf-2.72-ohos-arm64/
cp autoconf-2.72/COPYING.EXCEPTION autoconf-2.72-ohos-arm64/
cp autoconf-2.72/AUTHORS autoconf-2.72-ohos-arm64/

# 打包最终产物
tar -zcf autoconf-2.72-ohos-arm64.tar.gz autoconf-2.72-ohos-arm64
