
# 在iOS/OSX上编译libsecp256k1源码库

### 1.检查系统是否已经安装了homebrew，没有的话需要安装

homebrew官网：https://brew.sh

```shell
//打开终端

$ brew --version
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

```


#### 2.下载ios-autotools

地址：https://github.com/Elland/ios-autotools

> 使用ios-autotools需要你先在系统安装automake, autoconf, libtool。最简单可以使用homebrew进行安装：

```shell

$ brew install automake
$ brew install autoconf
$ brew install libtool

```

#### 3.编译libsecp256k1源码

- 下载libsecp256k1源码，地址：https://github.com/bitcoin-core/secp256k1
- 打开ios-autotools的文件夹，把iconfigure和autoframework复制到secp256k1的根本目录。




