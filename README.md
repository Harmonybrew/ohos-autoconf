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
hdc shell

# 需要先把根目录挂载为读写，才能创建 /opt 目录。
mount -o remount,rw /
mkdir -p /opt

cd /data
tar -zxf autoconf-2.72-ohos-arm64.tar.gz -C /opt
export PATH=$PATH:/opt/autoconf-2.72-ohos-arm64/bin

# 现在可以使用 autoconf 命令了
```

注意：一定要把这个压缩包解压到 /opt 目录，不能换成其他目录，具体原因请看下面的“常见问题”。

**3\. 在 [鸿蒙容器](https://github.com/hqzing/docker-mini-openharmony) 中使用**

在容器中用 curl 下载这个软件包，然后以“解压 + 配 PATH” 的方式使用。

示例：
```sh
docker run -itd --name=ohos ghcr.io/hqzing/docker-mini-openharmony:latest
docker exec -it ohos sh

cd /root
curl -L -O https://github.com/Harmonybrew/ohos-autoconf/releases/download/2.72/autoconf-2.72-ohos-arm64.tar.gz
tar -zxf autoconf-2.72-ohos-arm64.tar.gz -C /opt
export PATH=$PATH:/opt/autoconf-2.72-ohos-arm64/bin

# 现在可以使用 autoconf 命令了
```

注意：一定要把这个压缩包解压到 /opt 目录，不能换成其他目录，具体原因请看下面的“常见问题”。

## 从源码构建

**1\. 手动构建**

需要用一台 Linux x64 服务器来运行项目里的 build.sh，以实现 autoconf 的构建。

这里以 Ubuntu 24.04 x64 作为示例：
```sh
sudo apt update && sudo apt install -y make perl m4
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

如果你有特殊需求，不想或不能将它放在 /opt 目录，那你可以重新构建一版 autoconf，构建时把 prefix 改成你实际需要使用的路径。
