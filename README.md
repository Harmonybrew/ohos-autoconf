# ohos-autoconf

本项目为 OpenHarmony 平台构建了 autoconf，并发布预构建包。

## 获取预构建包

前往 [release 页面](https://github.com/Harmonybrew/ohos-autoconf/releases) 获取。

## 用法
**1\. 在鸿蒙 PC 中使用**

因系统安全规格限制等原因，暂不支持通过“解压 + 配 PATH” 的方式使用这个软件包。

你可以尝试将 tar 包打成 hnp 包再使用，详情请参考 [DevBox](https://gitcode.com/OpenHarmonyPCDeveloper/devbox) 的方案。

注意：打 hnp 包需要重新构建一版 autoconf，具体原因请看下面的“常见问题”。

**2\. 在鸿蒙开发板中使用**

用 hdc 把它推到设备上，然后以“解压 + 配 PATH” 的方式使用。

示例：
```sh
hdc file send autoconf-2.72-ohos-arm64.tar.gz /data
hdc file send perl-5.42.0-ohos-arm64.tar.gz /data
hdc file send m4-1.4.20-ohos-arm64.tar.gz /data
hdc shell

# 需要先把根目录挂载为读写，才能创建 /opt 目录。
mount -o remount,rw /
mkdir -p /data/opt
ln -s /data/opt /opt

cd /data
tar -zxf autoconf-2.72-ohos-arm64.tar.gz -C /opt
tar -zxf perl-5.42.0-ohos-arm64.tar.gz -C /opt
tar -zxf m4-1.4.20-ohos-arm64.tar.gz -C /opt
export PATH=$PATH:/opt/autoconf-2.72-ohos-arm64/bin
export PATH=$PATH:/opt/perl-5.42.0-ohos-arm64/bin
export PATH=$PATH:/opt/m4-1.4.20-ohos-arm64/bin

# 现在可以使用 autoconf 命令了
```

注意：
1. autoconf 依赖 perl 和 m4，用的时候要把这两个软件也一起装了
2. 一定要把 autoconf 和 perl 解压到 /opt 目录，不能换成其他目录，具体原因请看下面的“常见问题”。

**3\. 在 [鸿蒙容器](https://github.com/hqzing/docker-mini-openharmony) 中使用**

在容器中用 curl 下载这个软件包，然后以“解压 + 配 PATH” 的方式使用。

示例：
```sh
docker run -itd --name=ohos ghcr.io/hqzing/docker-mini-openharmony:latest
docker exec -it ohos sh

cd /root
curl -L -O https://github.com/Harmonybrew/ohos-autoconf/releases/download/2.72/autoconf-2.72-ohos-arm64.tar.gz
curl -L -O https://github.com/Harmonybrew/ohos-perl/releases/download/5.42.0/perl-5.42.0-ohos-arm64.tar.gz
curl -L -O https://github.com/Harmonybrew/ohos-m4/releases/download/1.4.20/m4-1.4.20-ohos-arm64.tar.gz
tar -zxf autoconf-2.72-ohos-arm64.tar.gz -C /opt
tar -zxf perl-5.42.0-ohos-arm64.tar.gz -C /opt
tar -zxf m4-1.4.20-ohos-arm64.tar.gz -C /opt
export PATH=$PATH:/opt/autoconf-2.72-ohos-arm64/bin
export PATH=$PATH:/opt/perl-5.42.0-ohos-arm64/bin
export PATH=$PATH:/opt/m4-1.4.20-ohos-arm64/bin

# 现在可以使用 autoconf 命令了
```

注意：
1. autoconf 依赖 perl 和 m4，用的时候要把这两个软件也一起装了
2. 一定要把 autoconf 和 perl 解压到 /opt 目录，不能换成其他目录，具体原因请看下面的“常见问题”。

## 从源码构建

**1\. 手动构建**

构建 autoconf 很容易，甚至不能称为“编译”，只能称为“构建”。构建过程并不需要编译器，只需要 make、perl、m4 这几个工具来进行脚本的加工。

由于鸿蒙版的 make、perl、m4 已经移植完成，本项目选择直接用这几个鸿蒙版的工具来进行 autoconf 的构建。

需要在 [鸿蒙容器](https://github.com/hqzing/docker-mini-openharmony) 中运行项目里的 build.sh，以实现 autoconf 的构建。

示例：
```sh
git clone https://github.com/Harmonybrew/ohos-autoconf.git
cd ohos-autoconf

docker run \
  --rm \
  -it \
  -v "$PWD":/workdir \
  -w /workdir \
  ghcr.io/hqzing/docker-mini-openharmony:latest \
  ./build.sh
```

**2\. 使用流水线构建**

如果你熟悉 GitHub Actions，你可以直接复用项目内的工作流配置，使用 GitHub 的流水线来完成构建。

这种情况下，你使用的是 GitHub 提供的构建机，不需要自己准备构建环境。

只需要这么做，你就可以进行你的个人构建：
1. Fork 本项目，生成个人仓
2. 在个人仓的“Actions”菜单里面启用工作流
3. 在个人仓提交代码或发版本，触发流水线运行

## 常见问题

**1\. 软件包对安装路径有要求**

如果不解压到 /opt 目录，这个软件包就无法正常使用。

因为 autoconf 这个软件并不是 portable/relocatable 的，你的实际使用目录必须要和构建时设置的 prefix 保持一致，这个软件才能正常工作。

本项目的构建脚本里面把 prefix 设置成了/opt/autoconf-2.72-ohos-arm64，因此在你的实际使用环境上也要让它位于这个目录。

同时，这版 autoconf 的解释器被硬编码改成了 /opt/perl-5.42.0-ohos-arm64/bin/perl，因此你也需要确保这个目录下有它要找的 perl 才能让它正常工作。

如果你有特殊需求，不想或不能将它放在 /opt 目录，那你可以重新构建一版 autoconf，构建时把 prefix 改成你实际需要使用的路径，并把解释器的路径改成你实际环境上的 perl 的绝对路径（请参考项目里面的 build.sh）。
