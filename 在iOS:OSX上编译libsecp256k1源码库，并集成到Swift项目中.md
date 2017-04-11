
# 在iOS/OSX上编译libsecp256k1源码库，并集成到Swift项目中

### 1.检查系统是否已经安装了homebrew，没有的话需要安装

homebrew官网：https://brew.sh

```shell
//打开终端

$ brew --version
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

```


### 2.下载ios-autotools

地址：https://github.com/Elland/ios-autotools

> 使用ios-autotools需要你先在系统安装automake, autoconf, libtool。最简单可以使用homebrew进行安装：

```shell

$ brew install automake
$ brew install autoconf
$ brew install libtool

```

### 3.编译libsecp256k1源码

- 下载libsecp256k1源码，地址：https://github.com/bitcoin-core/secp256k1
- 打开ios-autotools的文件夹，把iconfigure和autoframework复制到secp256k1的根本目录。
- ios-autotools支持使用iconfigure和autoframework编译源码库，推荐使用autoframework。

#### 使用iconfigure

配置iOS和Mac OSX的编译器，其中：armv7，armv7s，arm64为真机设备的架构，i386为32位模拟器，x86_64为64位模拟器。我们调试或真机测试都要有对应的价格编译版本。

```shell

$ ./iconfigure armv7|armv7s|arm64|i386|x86_64

```

配置好你需要编译的架构后，你就可以在在终端上交叉编译源码了。使用make和make install默认会导出静态库到系统目录 /opt/ 下，这样你可以多个项目进行引用。

你也可自定义一些导出设置:

```shell

 SDKVERSION   e.g.: 7.1
 PREFIX       e.g.: /User/Home/project/staticlib

```

还可以设置典型的配置参数，具体查看源码库支持的命令参数:

> CFLAGS CPPFLAGS CXXFLAGS LDFLAGS PKG_CONFIG_PATH

例如：编译一个静态库导出到你的项目，支持iOS SDK 7.1，支持ARM V7架构

```shell

SDKVERSION=7.1 PREFIX=/User/Home/project/staticlib 
./iconfigure armv7
make
make install

```

#### 使用autoframework【强烈推荐】

编译支持全部架构的iOS框架库，只要在包含configure脚本的源码库目录下，运行autoframework。

autoframework运行结果会创建2个目录，分别为：Static，存放所有架构的静态库.a文件；Frameworks，存放所有架构版本合并在一起的静态库二进制文件。

```shell
./autoframework Libsecp256k1 libsecp256k1.a
```

和iconfigure一样，提供可选的配置参数:

```shell

ARCHS    e.g. armv7 armv7s
PREFIX   e.g. /User/Home/project

```

现在我们要编译secp256k1，要支持armv7 armv7s arm64 x86_64 i386等架构，
执行：

```shell

ARCHS="armv7 armv7s arm64 x86_64 i386"
autoframework Libsecp256k1 libsecp256k1.a --enable-module-recovery

```

secp256k1的根目录下生产了Static和Frameworks两个文件夹。

### 4.把编译后的库集成到项目中。

通过autoframework我们可以得到静态库libsecp256k1.a文件和Libsecp256k1.framework。使用Libsecp256k1.framework相对简单一些，一个文件同时支持iOS和MacOSX，也支持bitcode。

#### Libsecp256k1.framework集成【强烈推荐】

- 把/Frameworks/Libsecp256k1.framework文件夹拖动你的项目根目录。
- 在/Frameworks/Libsecp256k1.framework/Headers/，创建Libsecp256k1.h文件。

```Objective-C

//导入库中的头文件
#import <Libsecp256k1/secp256k1.h>
#import <Libsecp256k1/secp256k1_recovery.h>

```

- 在/Frameworks/Libsecp256k1.framework/，创建/Modules/module.modulemap文件。

```Objective-C
//框架引用的模块名
framework module Libsecp256k1  {
    //配置刚才创建的头文件
    umbrella header "Libsecp256k1.h"

    export *
}

```

- 使用Xcode打开你的工程项目，把Libsecp256k1.framework添加到文件导航中。
- 查看Targets -> General -> Link Frameworks and Libraries是否存在Libsecp256k1.framework。
- 查看Targets -> Build Settings -> Framework Search Paths是否配置了框架路径。
- 以上都完成后，就可以在你的Swift文件中使用“import Libsecp256k1”导入框架。

#### libsecp256k1.a集成

- 把Static多个架构的静态库合并为一个大库，合成为libsecp256k1-all.a。

```shell

lipo -create Static/arm64/lib/libsecp256k1.a Static/armv7/lib/libsecp256k1.a Static/armv7s/lib/libsecp256k1.a Static/i386/lib/libsecp256k1.a Static/x86_64/lib/libsecp256k1.a -output Static/libsecp256k1-all.a

```

- 在工程项目创建路径/Frameworks/libs/，复制libsecp256k1-all.a到路径里面。
- 随便选择Static文件夹某个价格下的include的文件，复制到/Frameworks/下，并把include改名为Headers。
- 在/Frameworks/，创建/Modules/module.modulemap文件。

```Objective-C
//框架引用的模块名
framework module Libsecp256k1  {
    //配置头文件的相对module.modulemap的路径
    header "../../Headers/secp256k1.h"
    header "../../Headers/secp256k1_recovery.h"

    export *
}

```

- 在Targets -> Build Settings -> Header Search Paths添加“${SRCROOT}/Frameworks/Headers”。
- 在Targets -> Build Settings -> Library Search Paths添加“${SRCROOT}/Frameworks/libs”。
- 在Targets -> Build Settings -> Import Paths添加“${SRCROOT}/Frameworks/Modules”。
- 以上都完成后，就可以在你的Swift文件中使用“import Libsecp256k1”导入框架。
