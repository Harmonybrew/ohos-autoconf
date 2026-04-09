#!/bin/sh
set -e

WORKDIR=$(pwd)

# 如果存在旧的目录和文件，就清理掉
# 仅清理工作目录，不清理系统目录，因为默认用户每次使用新的容器进行构建（仓库中的构建指南是这么指导的）
rm -rf *.tar.gz \
    autoconf-2.72 \
    autoconf-2.72-ohos-arm64

# 下载一些命令行工具，并将它们软链接到 bin 目录中
cd /opt
echo "coreutils 9.10
busybox 1.37.0
grep 3.12
gawk 5.3.2
make 4.4.1
tar 1.35
gzip 1.14
perl 5.42.0
m4 1.4.20" >/tmp/tools.txt
while read -r name ver; do
    curl -fLO https://github.com/Harmonybrew/ohos-$name/releases/download/$ver/$name-$ver-ohos-arm64.tar.gz
done </tmp/tools.txt
ls | grep tar.gz$ | xargs -n 1 tar -zxf
rm -rf *.tar.gz
ln -sf $(pwd)/*-ohos-arm64/bin/* /bin/

cd $WORKDIR

# 构建 autoconf。这是个纯脚本软件，不需要编译器，有 make、perl、m4 就够了。
export M4=m4
curl -fLO https://ftp.gnu.org/gnu/autoconf/autoconf-2.72.tar.gz
tar -zxf autoconf-2.72.tar.gz
cd autoconf-2.72
./configure --prefix=/opt/autoconf-2.72-ohos-arm64
make -j$(nproc)
make install
cd ..

# 修改硬编码的 perl 解释器路径
find /opt/autoconf-2.72-ohos-arm64 -type f -exec sed -i "s@/usr/bin/perl@/opt/perl-5.42.0-ohos-arm64/bin/perl@g" {} +

# 履行开源义务，将 license 随制品一起发布
cp autoconf-2.72/COPYING /opt/autoconf-2.72-ohos-arm64
cp autoconf-2.72/COPYING.EXCEPTION /opt/autoconf-2.72-ohos-arm64
cp autoconf-2.72/AUTHORS /opt/autoconf-2.72-ohos-arm64

# 打包最终产物
cp -r /opt/autoconf-2.72-ohos-arm64 ./
tar -zcf autoconf-2.72-ohos-arm64.tar.gz autoconf-2.72-ohos-arm64

# 这一步是针对手动构建场景做优化。
# 在 docker run --rm -it 的用法下，有可能文件还没落盘，容器就已经退出并被删除，从而导致压缩文件损坏。
# 使用 sync 命令强制让文件落盘，可以避免那种情况的发生。
sync
