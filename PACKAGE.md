# RESP.app 打包和部署指南

本指南详细说明如何为 RESP.app (原 RedisDesktopManager) 构建和打包不同平台的发布版本。

## 📋 目录

- [快速开始](#快速开始)
- [环境准备](#环境准备)
- [构建流程](#构建流程)
- [打包流程](#打包流程)
- [平台特定说明](#平台特定说明)
- [故障排除](#故障排除)

## 🚀 快速开始

### 一键构建和打包

```bash
# 赋予执行权限
chmod +x build.sh package.sh

# 构建 Windows 版本
./build.sh windows 2024.1.0

# 打包 Windows 版本
./package.sh windows 2024.1.0

# 或者一步完成（当前平台）
./build.sh windows 2024.1.0 && ./package.sh windows 2024.1.0
```

## 🛠️ 环境准备

### Windows 环境

1. **安装 Qt 5.15.2+**

   ```bash
   # 下载并安装 Qt Open Source
   # 下载地址: https://download.qt.io/archive/qt/5.15/5.15.2/
   ```

2. **安装 Visual Studio 2019+**

   - 包含 Windows SDK
   - 安装 Visual C++ 构建工具

3. **安装 OpenSSL**

   ```bash
   # 下载 OpenSSL-Win64
   # 设置环境变量 OPENSSL_LIB_PATH
   ```

4. **安装 NSIS** (打包用)
   ```bash
   # 下载地址: https://nsis.sourceforge.io/
   ```

### macOS 环境

1. **安装 Xcode 命令行工具**

   ```bash
   xcode-select --install
   ```

2. **安装 Qt 5.15.2+**

   ```bash
   # 使用 Homebrew 安装（Qt Charts 已包含在 qt@5 中）
   brew install qt@5

   # 将 Qt 添加到 PATH（M1/ARM Mac）
   echo 'export PATH="/opt/homebrew/opt/qt@5/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc

   # 或者对于 Intel Mac
   # echo 'export PATH="/usr/local/opt/qt@5/bin:$PATH"' >> ~/.zshrc
   ```

3. **验证安装**

   ```bash
   # 检查 qmake 版本
   qmake --version

   # 检查 macdeployqt 是否可用
   which macdeployqt
   ```

### Linux 环境

1. **安装依赖**

   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install qtbase5-dev qtdeclarative5-dev qtquickcharts5-dev
   sudo apt-get install qt5-qmake qttools5-dev-tools build-essential
   sudo apt-get install liblz4-dev libzstd-dev libbrotli-dev libsnappy-dev

   # CentOS/RHEL/Fedora
   sudo dnf install qt5-qtbase-devel qt5-qtdeclarative-devel qt5-qtcharts-devel
   sudo dnf install qt5-qttools-devel gcc-c++ make
   sudo dnf install lz4-devel zstd-devel brotli-devel snappy-devel
   ```

2. **可选：打包工具**
   ```bash
   # Debian 包
   sudo apt-get install dpkg-dev
   ```

## 🔨 构建流程

### 使用自动化脚本

```bash
# 构建 Windows
./build.sh windows [版本号]

# 构建 macOS
./build.sh macos [版本号]

# 构建 Linux
./build.sh linux [版本号]

# 构建当前平台
./build.sh all [版本号]

# 清理构建文件
./build.sh clean
```

### 手动构建步骤

#### Windows 手动构建

```bash
cd src

# 配置项目
qmake "CONFIG+=release" \
       "DEFINES+=APP_VERSION=\\\"2024.1.0\\\"" \
       "SYSTEM_LZ4=1" "SYSTEM_ZSTD=1" "SYSTEM_SNAPPY=1" "SYSTEM_BROTLI=1"

# 编译
nmake
# 或使用 make (MinGW)
make -j4

# 输出：../bin/windows/release/resp.exe
```

#### macOS 手动构建

```bash
cd src

# 配置项目
qmake "CONFIG+=release" \
       "DEFINES+=APP_VERSION=\\\"2024.1.0\\\"" \
       "SYSTEM_LZ4=1" "SYSTEM_ZSTD=1" "SYSTEM_SNAPPY=1" "SYSTEM_BROTLI=1"

# 编译
make -j$(sysctl -n hw.ncpu)

# 部署 Qt 框架
macdeployqt ../bin/osx/release/RESP.app

# 输出：../bin/osx/release/RESP.app
```

#### Linux 手动构建

```bash
cd src

# 配置项目
qmake "CONFIG+=release" \
       "DEFINES+=APP_VERSION=\\\"2024.1.0\\\"" \
       "SYSTEM_LZ4=1" "SYSTEM_ZSTD=1" "SYSTEM_SNAPPY=1" "SYSTEM_BROTLI=1" \
       "CLEAN_RPATH=1"

# 编译
make -j$(nproc)

# 设置执行权限
chmod +x ../bin/linux/release/resp

# 输出：../bin/linux/release/resp
```

## 📦 打包流程

### 使用自动化脚本

```bash
# 打包 Windows
./package.sh windows [版本号]

# 打包 macOS
./package.sh macos [版本号]

# 打包 Linux
./package.sh linux [版本号]

# 打包所有平台（基于当前构建）
./package.sh all [版本号]

# 清理打包文件
./package.sh clean
```

### Windows 打包 (NSIS)

**自动化打包：**

```bash
./package.sh windows 2024.1.0
# 输出：packages/2024.1.0/resp-2024.1.0.exe
```

**手动打包：**

```bash
cd build/windows/installer

# 编辑版本号（如果需要）
sed -i 's/resp-VERSION/resp-2024.1.0/g' installer.nsi

# 运行 NSIS
makensis installer.nsi
```

**安装程序特性：**

- 64 位仅支持
- 自动升级检测
- Visual C++ 运行时安装
- 开始菜单和桌面快捷方式
- 完整的注册表集成
- 自动卸载支持

### macOS 打包 (DMG)

**自动化打包：**

```bash
./package.sh macos 2024.1.0
# 输出：packages/2024.1.0/RESP-2024.1.0.dmg
```

**手动打包：**

```bash
# 1. 部署 Qt 框架
macdeployqt bin/osx/release/RESP.app

# 2. 更新 Info.plist
cp src/resources/Info.plist.sample bin/osx/release/RESP.app/Contents/Info.plist
sed -i '' 's/0.0.0/2024.1.0/g' bin/osx/release/RESP.app/Contents/Info.plist

# 3. 创建 DMG
mkdir dmg_temp
cp -R bin/osx/release/RESP.app dmg_temp/
ln -s /Applications dmg_temp/Applications

hdiutil create -volname "RESP" \
             -srcfolder dmg_temp \
             -ov -format UDZO \
             RESP-2024.1.0.dmg

rm -rf dmg_temp
```

**DMG 特性：**

- 标准 macOS 应用程序包
- 应用程序链接到 /Applications
- 高 DPI 支持
- 自动图形切换
- macOS 10.14+ 最低支持

### Linux 打包

**自动化打包：**

```bash
./package.sh linux 2024.1.0
# 输出：
# - packages/2024.1.0/RESP-2024.1.0-linux-x86_64.tar.gz
# - packages/2024.1.0/resp-app_2024.1.0_amd64.deb (如果可用)
```

**手动打包：**

```bash
# 1. 创建包结构
mkdir -p resp_app_pkg/opt/resp_app
mkdir -p resp_app_pkg/usr/share/applications

# 2. 复制文件
cp bin/linux/release/resp resp_app_pkg/opt/resp_app/
cp -r lib/* resp_app_pkg/opt/resp_app/lib/ 2>/dev/null || true
cp src/resources/qt.conf resp_app_pkg/opt/resp_app/
cp src/resources/resp.desktop resp_app_pkg/usr/share/applications/

# 3. 创建安装脚本
cat > resp_app_pkg/install.sh << 'EOF'
#!/bin/bash
# 安装脚本内容
EOF

# 4. 创建压缩包
cd resp_app_pkg
tar -czf ../RESP-2024.1.0-linux-x86_64.tar.gz .
cd ..
rm -rf resp_app_pkg
```

**包格式：**

- **TAR.GZ**: 通用压缩包，包含安装脚本
- **DEB**: Debian/Ubuntu 包，自动依赖管理
- **安装路径**: `/opt/resp_app`
- **桌面集成**: 自动创建 .desktop 文件

## 🖥️ 平台特定说明

### Windows 特性

- **架构**: 仅支持 64 位 (x86_64)
- **依赖检查**: 自动安装 Visual C++ Redistributable
- **升级**: 自动检测和升级旧版本
- **卸载**: 完整的卸载和清理
- **注册表**: 遵循 Windows 安装标准

### macOS 特性

- **代码签名**: 支持开发者签名和公证
- **沙盒**: 可配置应用沙盒
- **自动更新**: 支持 Sparkle 更新框架
- **深色模式**: 自动适配系统主题
- **视网膜**: 高 DPI 显示支持

### Linux 特性

- **包管理器**: 支持 apt、dnf、pacman 等
- **依赖解析**: 自动安装 Qt 和系统依赖
- **系统集成**: 桌面文件、图标、MIME 类型
- **便携模式**: 支持便携式运行
- **多架构**: 理论支持 ARM64 (需要适配)

## 🔧 故障排除

### 构建问题

**问题**: `qmake: command not found`

```bash
# 解决方案
export PATH=$PATH:/path/to/qt/bin
# 或
sudo apt-get install qt5-qmake  # Linux
```

**问题**: `fatal error: 'QtCharts/QChartView': file not found`

```bash
# 解决方案
# 确保安装了 Qt Charts 模块
# 重新配置 qmake
qmake "CONFIG+=release" "QT+=charts"
```

**问题**: 链接错误 - 找不到 OpenSSL

```bash
# 解决方案 (Windows)
set OPENSSL_LIB_PATH=C:\OpenSSL-Win64\lib\VC

# 解决方案 (Linux)
sudo apt-get install libssl-dev
```

### 打包问题

**问题**: Windows 安装程序大小过大

```bash
# 解决方案
# 在 installer.nsi 中启用压缩
SetCompressor /SOLID /FINAL lzma
```

**问题**: macOS DMG 无法在旧系统上运行

```bash
# 解决方案
# 检查最低系统版本
# 在 Info.plist 中设置 LSMinimumSystemVersion
```

**问题**: Linux 依赖未满足

```bash
# 解决方案
# 安装系统依赖
sudo apt-get install libqt5charts5 libqt5gui5 libqt5core5a

# 或使用静态链接
qmake "CONFIG+=static"
```

### 运行时问题

**问题**: Windows 提示缺少 DLL

```bash
# 解决方案
# 使用依赖检查工具
# 安装 Visual C++ Redistributable
# 或静态链接依赖库
```

**问题**: macOS Gatekeeper 阻止运行

```bash
# 解决方案
# 代码签名应用
codesign --force --deep --sign "Developer ID" RESP.app

# 公证应用 (需要)
xcrun altool --notarize-app --primary-bundle-id "com.redisdesktop.rdm" \
               --username "developer@example.com" \
               --password "app-password" \
               --file RESP.app.dmg
```

**问题**: Linux 权限被拒绝

```bash
# 解决方案
chmod +x bin/linux/release/resp
# 或使用 sudo 安装
sudo ./install.sh
```

## 📊 构建和打包矩阵

| 平台    | 构建工具      | 打包工具       | 输出格式      | 依赖                          |
| ------- | ------------- | -------------- | ------------- | ----------------------------- |
| Windows | qmake + nmake | NSIS           | .exe          | Qt 5.15+, VC++ 2019+, OpenSSL |
| macOS   | qmake + make  | hdiutil        | .dmg          | Qt 5.15+, Xcode tools         |
| Linux   | qmake + make  | tar + dpkg-deb | .tar.gz, .deb | Qt 5.15+, system libs         |

## 🎯 最佳实践

1. **版本管理**: 统一使用语义化版本号
2. **依赖管理**: 优先使用系统库，减少包大小
3. **测试**: 在干净环境中测试安装程序
4. **签名**: 对发布包进行代码签名
5. **文档**: 提供详细的发布说明和升级指南

## 📚 参考资源

- [Qt 官方文档](https://doc.qt.io/)
- [NSIS 文档](https://nsis.sourceforge.io/Docs/)
- [Apple 代码签名指南](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [Debian 打包指南](https://www.debian.org/doc/manuals/debian-faq/ch-pkg_basics)
- [Linux 桌面集成规范](https://www.freedesktop.org/wiki/Specifications/)

---

**注意**: 本指南基于 RESP.app 项目代码分析生成，实际打包可能需要根据具体环境进行调整。
