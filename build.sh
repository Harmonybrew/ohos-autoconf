#!/bin/sh
set -e

# 如果存在旧的目录和文件，就清理掉
# 仅清理工作目录，不清理系统目录，因为默认用户每次使用新的容器进行构建（仓库中的构建指南是这么指导的）
rm -rf *.tar.gz \
    autoconf-2.72 \
    autoconf-2.72-ohos-arm64

# 准备一些杂项的命令行工具
curl -L -O https://github.com/Harmonybrew/ohos-coreutils/releases/download/9.9/coreutils-9.9-ohos-arm64.tar.gz
curl -L -O https://github.com/Harmonybrew/ohos-grep/releases/download/3.12/grep-3.12-ohos-arm64.tar.gz
curl -L -O https://github.com/Harmonybrew/ohos-gawk/releases/download/5.3.2/gawk-5.3.2-ohos-arm64.tar.gz
tar -zxf coreutils-9.9-ohos-arm64.tar.gz -C /opt
tar -zxf grep-3.12-ohos-arm64.tar.gz -C /opt
tar -zxf gawk-5.3.2-ohos-arm64.tar.gz -C /opt

# 准备鸿蒙版 make、perl、m4
curl -L -O https://github.com/Harmonybrew/ohos-make/releases/download/4.4.1/make-4.4.1-ohos-arm64.tar.gz
curl -L -O https://github.com/Harmonybrew/ohos-perl/releases/download/5.42.0/perl-5.42.0-ohos-arm64.tar.gz
curl -L -O https://github.com/Harmonybrew/ohos-m4/releases/download/1.4.20/m4-1.4.20-ohos-arm64.tar.gz
tar -zxf make-4.4.1-ohos-arm64.tar.gz -C /opt
tar -zxf perl-5.42.0-ohos-arm64.tar.gz -C /opt
tar -zxf m4-1.4.20-ohos-arm64.tar.gz -C /opt

# 设置环境变量
export PATH=/opt/coreutils-9.9-ohos-arm64/bin:$PATH
export PATH=/opt/grep-3.12-ohos-arm64/bin:$PATH
export PATH=/opt/gawk-5.3.2-ohos-arm64/bin:$PATH
export PATH=/opt/make-4.4.1-ohos-arm64/bin:$PATH
export PATH=/opt/perl-5.42.0-ohos-arm64/bin:$PATH
export PATH=/opt/m4-1.4.20-ohos-arm64/bin:$PATH
export M4=m4

# 构建 autoconf。这是个纯脚本软件，不需要编译器，有 make、perl、m4 就够了。
curl -L -O http://mirrors.ustc.edu.cn/gnu/autoconf/autoconf-2.72.tar.gz
tar -zxf autoconf-2.72.tar.gz
cd autoconf-2.72
./configure --prefix=/opt/autoconf-2.72-ohos-arm64 --host=aarch64-linux
make -j$(nproc)
make install
cd ..

# 履行开源义务，将 license 随制品一起发布
cp autoconf-2.72/COPYING /opt/autoconf-2.72-ohos-arm64
cp autoconf-2.72/COPYING.EXCEPTION /opt/autoconf-2.72-ohos-arm64
cp autoconf-2.72/AUTHORS /opt/autoconf-2.72-ohos-arm64

# 修改硬编码的 perl 解释器路径
find /opt/autoconf-2.72-ohos-arm64 -type f -exec sed -i "s@/usr/bin/perl@/opt/perl-5.42.0-ohos-arm64/bin/perl@g" {} +

# 打包最终产物
cp -r /opt/autoconf-2.72-ohos-arm64 ./
tar -zcf autoconf-2.72-ohos-arm64.tar.gz autoconf-2.72-ohos-arm64

# 这一步是针对手动构建场景做优化。
# 在 docker run --rm -it 的用法下，有可能文件还没落盘，容器就已经退出并被删除，从而导致压缩文件损坏。
# 使用 sync 命令强制让文件落盘，可以避免那种情况的发生。
sync
