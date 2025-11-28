# RESP.app - Open Source GUI for Redis®

**RESP.app** (原 RedisDesktopManager) 是一个功能强大的跨平台 Redis 数据库管理工具，提供直观的图形界面来管理 Redis 数据结构。它支持所有 Redis 数据类型，提供高级功能如批量操作、SSH 隧道、SSL/TLS 加密，以及云 Redis 服务集成。

## ✨ 核心特性

### 🚀 多平台支持
- **Windows** - Windows 10+ (64位)
- **macOS** - macOS 10.14+ (Intel & Apple Silicon)
- **Linux** - 支持主流发行版 (Ubuntu, Debian, Fedora, CentOS, Arch)

### 🗄️ 完整的 Redis 数据类型支持
- **String** - 文本和二进制数据
- **Hash** - 键值对集合
- **List** - 有序字符串列表
- **Set** - 无序唯一字符串集合
- **Sorted Set** - 有序集合
- **Stream** - Redis Streams 消息队列
- **HyperLogLog** - 基数统计
- **Bitmap** - 位图操作
- **GEO** - 地理位置数据

### 🔧 高级功能
- **批量操作** - 大规模数据的导入导出和批量处理
- **连接管理** - 同时管理多个 Redis 连接
- **值编辑器** - 多格式化显示和编辑 (JSON, HEX, XML, YAML, MessagePack)
- **控制台** - 内置 Redis 命令行界面
- **SSH 隧道** - 安全连接远程 Redis 实例
- **SSL/TLS 加密** - 加密连接传输
- **云服务集成** - 支持 AWS ElastiCache, Azure Redis Cache, Redis Labs 等
- **扩展系统** - 插件架构，支持自定义格式化器和功能扩展
- **实时监控** - 服务器状态和性能监控
- **暗色模式** - 自适应系统主题

### 📊 数据可视化
- **内存分析** - Redis 内存使用情况分析
- **键空间管理** - 键空间的可视化管理
- **统计信息** - 详细的 Redis 服务器统计
- **性能监控** - 实时性能指标监控

## 🚀 快速开始

### 安装

#### Windows
1. 下载 Windows 安装程序从 [resp.app/subscriptions](http://resp.app/subscriptions)
2. 运行安装程序并按照向导操作
3. 安装完成后从开始菜单或桌面快捷方式启动

#### macOS
1. 下载 DMG 文件从 [resp.app/subscriptions](http://resp.app/subscriptions)
2. 挂载 DMG 并将 RESP.app 拖拽到 Applications 文件夹
3. 从 Launchpad 或 Applications 文件夹启动应用

#### Linux
```bash
# 使用 Flatpak (推荐)
flatpak install flathub app.resp.RESP

# 使用 Snap
sudo snap install redis-desktop-manager

# 从源码构建
./build.sh linux && ./package.sh linux
```

### 首次连接

1. **启动 RESP.app** 并点击 "Connect to Redis Server"
2. **配置连接信息**：
   - **名称**: 连接的显示名称 (例如: 本地Redis)
   - **主机**: Redis 服务器地址 (例如: localhost)
   - **端口**: Redis 服务器端口 (默认: 6379)
   - **密码**: Redis 认证密码 (可选)
   - **用户名**: Redis 6.0+ ACL 用户名 (可选)
3. **测试连接**: 点击 "Test Connection" 验证配置
4. **保存连接**: 确认无误后保存连接设置

### SSL/TLS 连接

对于安全的 Redis 连接，在 "SSL/TLS" 选项卡中：

1. 启用 "Use SSL Protocol"
2. 提供 PEM 格式的公钥证书
3. 配置私钥和证书颁发机构文件 (如需要)

**支持的云服务**：
- **AWS ElastiCache**: 支持通过 VPN 或 SSH 隧道连接
- **Microsoft Azure Redis Cache**: 完整的 SSL 配置支持
- **Redis Labs**: 直接连接或通过 In-Transit Encryption
- **DigitalOcean Managed Redis**: 配置连接参数

### SSH 隧道

对于无法直接访问的 Redis 服务器：

1. 启用 "SSH Tunnel" 选项
2. 配置 SSH 服务器信息：
   - SSH 主机和端口
   - SSH 用户名和认证方式
   - 本地和远程端口映射
3. RESP.app 将通过 SSH 隧道安全连接到 Redis

## 🔧 构建和开发

### 环境要求

**通用依赖**：
- Qt 5.15.2+ (包含 qtcharts 模块)
- qredisclient (Redis 客户端库)
- CMake 3.15+ (某些第三方依赖)
- Git (获取源码)

**平台特定**：
- **Windows**: Visual Studio 2019+, Windows SDK, OpenSSL-Win64
- **macOS**: Xcode 命令行工具, macOS 10.14+
- **Linux**: gcc/clang, 系统开发包 (liblz4-dev, libzstd-dev, 等)

### 快速构建

```bash
# 克隆仓库
git clone --recursive git@github.com:kurisu994/RedisDesktopManager.git rdm
cd rdm

# 构建 (选择平台)
./build.sh windows 2024.1.0    # Windows
./build.sh macos 2024.1.0      # macOS
./build.sh linux 2024.1.0      # Linux
```

### 打包发布

```bash
# 打包所有平台
./package.sh all 2024.1.0

# 打包特定平台
./package.sh windows 2024.1.0  # Windows EXE
./package.sh macos 2024.1.0    # macOS DMG
./package.sh linux 2024.1.0    # Linux TAR.GZ + DEB
```

详细的构建和打包指南请参考 [PACKAGE.md](PACKAGE.md)。

### 开发设置

```bash
# 安装开发依赖
# Linux
sudo apt-get install qtbase5-dev qtdeclarative5-dev qtquickcharts5-dev qt5-qmake

# macOS
brew install qt@5 qtcharts cmake

# Windows (使用 vcpkg)
vcpkg install qt5 qt5-charts openssl

# 运行测试
cd tests
qmake && make
./tests

# 构建 Qt 项目
cd src
qmake "CONFIG+=debug" "DEFINES+=APP_VERSION=\\\"dev\\\""
make
```

## 📚 项目架构

### 技术栈
- **前端**: Qt QML + JavaScript (响应式 UI)
- **后端**: C++17 (高性能业务逻辑)
- **网络**: Qt Network (异步 I/O)
- **构建**: qmake + CMake (跨平台构建)
- **测试**: Qt Test Framework + C++ Unit Tests

### 核心模块

```
src/
├── app/                    # 应用程序核心
│   ├── app.cpp/.h         # 主应用程序类
│   ├── connectionsmanager.* # 连接管理
│   ├── qmlutils.*          # QML 工具函数
│   └── jsonutils.*         # JSON 处理工具
├── models/                 # 数据模型
│   ├── connectionconf.*      # 连接配置模型
│   ├── key-models/         # Redis 数据类型模型
│   └── configmanager.*     # 配置管理
├── modules/               # 功能模块
│   ├── connections-tree/     # 连接树形界面
│   ├── console/             # Redis 控制台
│   ├── value-editor/        # 值编辑器
│   ├── bulk-operations/     # 批量操作
│   ├── server-actions/       # 服务器操作
│   ├── extension-server/     # 扩展服务器
│   └── common/              # 通用工具
├── qml/                   # QML 用户界面
├── resources/               # 资源文件
└── py/                     # Python 扩展
```

### 第三方依赖

```
3rdparty/
├── qredisclient/           # Redis 客户端库
├── pyotherside/            # Python 集成框架
├── simdjson/               # 高性能 JSON 解析器
├── lz4/                    # LZ4 压缩库
├── zstd/                   # ZSTD 压缩库
├── snappy/                 # Snappy 压缩库
├── brotli/                 # Brotli 压缩库
└── fakeit/                 # C++ 模拟测试框架
```

## 🔌 扩展和插件

### 扩展服务器

RESP.app 提供内置的 HTTP 服务器来支持扩展功能：

- **格式化器**: 支持自定义数据格式显示
- **插件系统**: 第三方开发者可以创建扩展
- **API 接口**: RESTful API 用于外部集成

### Python 集成

通过 PyOtherSide 框架，RESP.app 可以：

- 执行 Python 脚本
- 使用 Python 生态系统的库
- 扩展数据处理能力
- 自定义业务逻辑

## 🧪 测试

### 运行测试

```bash
# 单元测试
cd tests/unit_tests
qmake && make
./tests -platform minimal

# QML 界面测试
cd tests/qml_tests
qmake && make
./qml_tests -platform minimal

# 集成测试
cd tests
qmake "DEFINES+=INTEGRATION_TESTS" && make
./tests
```

### 测试覆盖

- **连接测试**: 各种 Redis 服务器和配置
- **数据类型测试**: 所有 Redis 数据类型的 CRUD 操作
- **UI 测试**: 用户界面交互和响应性
- **性能测试**: 大数据量下的性能表现
- **集成测试**: 与第三方服务的集成

## 📖 文档和资源

### 官方文档
- **主要文档**: [resp.app/docs](https://resp.app/docs)
- **快速开始**: [快速开始指南](docs/quick-start.md)
- **安装指南**: [详细安装说明](docs/install.md)
- **API 参考**: [扩展服务器 API](docs/extension-server.md)
- **FAQ**: [常见问题解答](docs/faq.md)

### 相关资源
- **Redis 官方文档**: [redis.io/documentation](https://redis.io/documentation)
- **Redis 命令参考**: [redis.io/commands](https://redis.io/commands)
- **Qt 文档**: [doc.qt.io](https://doc.qt.io/)
- **下载**: [resp.app/subscriptions](http://resp.app/subscriptions)

## 🤝 贡献指南

### 如何贡献

我们欢迎社区贡献！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详细的贡献流程。

### 贡献类型

- **🐛 Bug 报告**: 发现并报告问题
- **✨ 功能请求**: 提出新功能想法
- **📝 文档改进**: 完善项目文档
- **🌐 翻译**: 帮助多语言支持
- **🧪 测试**: 提供测试用例和测试覆盖
- **💻 代码贡献**: 提交代码改进和新功能

### 开发流程

1. **Fork 项目**: 在 GitHub 上 fork 仓库
2. **创建分支**: 基于主分支创建功能分支
3. **开发**: 实现功能或修复问题
4. **测试**: 确保测试通过且不破坏现有功能
5. **提交**: 创建 Pull Request 到主分支

### 代码规范

- 遵循现有的代码风格
- 添加适当的注释和文档
- 确保跨平台兼容性
- 运行静态分析和测试

## 📄 许可证

本项目采用 [自定义许可证](LICENSE)，允许自由使用、修改和分发。

### 第三方许可证

- Qt: [LGPLv3](https://www.qt.io/licensing/)
- qredisclient: [BSD](https://github.com/uglide/qredisclient)
- 其他依赖: 各自的开源许可证

## 🎯 路线图

- [x] **多平台支持** - Windows, macOS, Linux 完全支持
- [x] **Redis 7.0 兼容** - 支持最新 Redis 版本特性
- [x] **ARM64 支持** - Apple Silicon 和 ARM Linux 原生支持
- [x] **云端集成** - 完整的云服务集成
- [x] **高 DPI 支持** - 现代显示器的完美支持
- [ ] **移动应用** - iOS 和 Android 客户端 (计划中)
- [ ] **Web 界面** - 基于浏览器的 Redis 管理工具 (考虑中)
- [ ] **集群管理** - Redis Cluster 的专门支持 (改进中)
- [ ] **容器化部署** - Docker 和 Kubernetes 部署支持

## 🔗 链接

- **主页**: [resp.app](https://resp.app)
- **下载**: [resp.app/subscriptions](http://resp.app/subscriptions)
- **GitHub**: [github.com/kurisu994/RedisDesktopManager](https://github.com/kurisu994/RedisDesktopManager)
- **文档**: [resp.app/docs](https://resp.app/docs)
- **博客**: [Redis 公告](https://redis.com/blog/respapp-joining-redis/)

---