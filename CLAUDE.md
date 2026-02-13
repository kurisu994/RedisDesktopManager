# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 构建系统

RESP.app 使用 qmake 构建系统，这是一个基于 Qt 的项目。

### 主要构建文件
- `src/resp.pro` - 主应用程序构建配置
- `tests/tests.pro` - 测试项目根配置
- `tests/unit_tests/unit_tests.pro` - C++ 单元测试配置
- `tests/qml_tests/qml_tests.pro` - QML 测试配置

### 构建命令
```bash
# 构建主应用程序
cd src
qmake "SYSTEM_LZ4=1" "SYSTEM_ZSTD=1" "SYSTEM_SNAPPY=1" "SYSTEM_BROTLI=1"
make

# 构建并运行测试
cd tests
qmake "SYSTEM_LZ4=1" "SYSTEM_ZSTD=1" "SYSTEM_SNAPPY=1" "SYSTEM_BROTLI=1" DEFINES+=INTEGRATION_TESTS
make -j 2

# 运行 C++ 测试
./../bin/tests/tests -platform minimal -txt

# 运行 QML 测试
./../bin/tests/qml_tests -platform minimal -txt
```

### 依赖要求
- Qt 6 或更高版本，需要 qtcharts 模块
- 系统库：LZ4, ZSTD, Snappy, Brotli
- CMake (用于某些第三方依赖)
- Redis 服务器 (用于集成测试)

## 项目架构

### 核心目录结构
- `src/app/` - 应用程序核心逻辑和模型
- `src/models/` - 数据模型（连接、配置等）
- `src/models/key-models/` - Redis 键类型模型（Hash, List, Set 等）
- `src/modules/` - 功能模块
  - `connections-tree/` - 连接树形结构管理
  - `console/` - Redis 控制台
  - `value-editor/` - 值编辑器
  - `bulk-operations/` - 批量操作
  - `server-actions/` - 服务器操作
  - `extension-server/` - 扩展服务器客户端
  - `common/` - 通用工具和模型
- `src/qml/` - QML 用户界面文件
- `src/resources/` - 资源文件（图标、图片等）
- `3rdparty/` - 第三方依赖库

### 关键技术特性
- **Qt QML/C++ 混合架构**: UI 使用 QML，业务逻辑使用 C++
- **模型-视图架构**: 使用 Qt 的模型-视图框架
- **异步网络操作**: 基于 Qt 的异步网络处理
- **多连接支持**: 可同时管理多个 Redis 连接
- **键类型支持**: 支持所有 Redis 数据类型（String, Hash, List, Set, ZSet, Stream 等）
- **批量操作**: 支持大规模数据的导入导出和批量操作
- **扩展系统**: 内置扩展服务器，支持插件开发

### 主要组件
- `connections-manager` - Redis 连接管理
- `value-editor` - 值编辑器，支持多种格式化器
- `console` - Redis 命令控制台
- `bulk-operations` - 批量操作框架

## 测试

测试分为 C++ 单元测试和 QML 界面测试：

- **单元测试位置**: `tests/unit_tests/testcases/`
- **QML 测试位置**: `tests/qml_tests/tst_*.qml`
- **测试运行**: 使用 GitHub Actions 或本地构建运行

## 开发工具

### 性能分析
使用 Valgrind 和 Massif 进行内存和性能分析：
```bash
valgrind --tool=massif --massif-out-file=resp.massif ./resp
massif-visualizer resp.massif
```

### 调试 SSL 连接
```bash
openssl s_client -connect HOST:PORT -cert cert.crt -key key.key -CAfile ca.pem
```

## 平台特定构建

### Linux
- 目标安装路径：`/opt/resp_app`
- 包含桌面文件和图标安装
- 支持系统集成

### macOS
- 应用程序包结构
- 图标和信息清单配置
- 支持深色模式

### Windows
- NSIS 安装程序配置
- Visual C++ 运行时库集成
- 图标和版本信息

## 第三方依赖

主要第三方库位于 `3rdparty/` 目录：
- `qredisclient` - Redis 客户端库
- `pyotherside` - Python 集成
- `simdjson` - 高性能 JSON 解析器
- 各种压缩库（LZ4, ZSTD, Snappy, Brotli）

所有第三方库都是作为 Git 子模块包含的。