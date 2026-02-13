#!/bin/bash

# RESP.app 构建脚本
# 支持 Windows, macOS, Linux 三个平台的构建
#
# 用法: ./build.sh [windows|macos|linux] [版本号]

set -e

# 默认版本号 - 从环境变量或命令行参数获取
if [ -z "$VERSION" ]; then
    if [ -n "$2" ]; then
        VERSION="$2"
    else
        VERSION="2026.2.0"
    fi
fi

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查必要的工具
check_requirements() {
    local platform=$1
    log_info "检查 $platform 构建环境..."

    case $platform in
        windows)
            if ! command -v qmake &> /dev/null; then
                log_error "qmake 未找到，请安装 Qt"
                exit 1
            fi
            if ! command -v make &> /dev/null && ! command -v nmake &> /dev/null; then
                log_error "make 或 nmake 未找到，请安装构建工具"
                exit 1
            fi
            ;;
        macos)
            if ! command -v qmake &> /dev/null; then
                log_error "qmake 未找到，请安装 Qt"
                exit 1
            fi
            if ! command -v make &> /dev/null; then
                log_error "make 未找到，请安装 Xcode 命令行工具"
                exit 1
            fi
            ;;
        linux)
            if ! command -v qmake &> /dev/null; then
                log_error "qmake 未找到，请安装 qt6-qmake"
                exit 1
            fi
            if ! command -v make &> /dev/null; then
                log_error "make 未找到，请安装 build-essential"
                exit 1
            fi
            ;;
        *)
            log_error "不支持的系统: $platform"
            exit 1
            ;;
    esac
}

# 清理之前的构建
clean_build() {
    log_info "清理之前的构建文件..."

    # 清理主项目
    if [ -f "Makefile" ]; then
        make clean
        rm -f Makefile
    fi

    # 清理 bin 目录
    rm -rf bin/

    # 清理 obj 文件
    find . -name "*.o" -delete
    find . -name "obj" -type d -exec rm -rf {} +

    # 清理 qmake 生成文件
    find . -name ".qmake.stash" -delete
    find . -name "*.pro.user" -delete

    log_success "清理完成"
}

# 构建 Windows 版本
build_windows() {
    log_info "开始构建 Windows 版本 (版本: $VERSION)..."

    check_requirements "windows"

    cd src

    # 配置 qmake 项目
    log_info "配置 qmake 项目..."
    qmake "CONFIG+=release" "CONFIG-=debug" "DEFINES+=APP_VERSION=\\\"$VERSION\\\"" \
           "SYSTEM_LZ4=1" "SYSTEM_ZSTD=1" "SYSTEM_SNAPPY=1" "SYSTEM_BROTLI=1"

    # 编译
    log_info "编译项目..."
    if command -v nmake &> /dev/null; then
        nmake
    else
        make -j$(nproc 2>/dev/null || echo 4)
    fi

    # 检查输出
    if [ ! -f "../bin/windows/release/resp.exe" ]; then
        log_error "构建失败，未找到 resp.exe"
        exit 1
    fi

    cd ..
    log_success "Windows 版本构建完成: bin/windows/release/resp.exe"
}

# 构建 macOS 版本
build_macos() {
    log_info "开始构建 macOS 版本 (版本: $VERSION)..."

    check_requirements "macos"

    cd src

    # 配置 qmake 项目
    log_info "配置 qmake 项目..."
    qmake "CONFIG+=release" "CONFIG-=debug" "DEFINES+=APP_VERSION=\\\"$VERSION\\\"" \
           "SYSTEM_LZ4=1" "SYSTEM_ZSTD=1" "SYSTEM_SNAPPY=1" "SYSTEM_BROTLI=1"

    # 编译
    log_info "编译项目..."
    make -j$(sysctl -n hw.ncpu 2>/dev/null || echo 4)

    # 检查输出
    if [ ! -d "../bin/osx/release/RESP.app" ]; then
        log_error "构建失败，未找到 RESP.app"
        exit 1
    fi

    # 部署 Qt 框架
    if ! command -v macdeployqt &> /dev/null; then
        log_warning "macdeployqt 未找到，请手动部署 Qt 框架"
    else
        log_info "部署 Qt 框架..."
        macdeployqt "../bin/osx/release/RESP.app" -qmldir=qml

        # 复制额外的库文件
        if [ -d "lib" ]; then
            mkdir -p "../bin/osx/release/RESP.app/Contents/Frameworks"
            cp -r lib/* "../bin/osx/release/RESP.app/Contents/Frameworks/"
        fi

        # Ad-hoc 代码签名
        log_info "对应用程序进行代码签名..."
        codesign --force --deep --sign - "../bin/osx/release/RESP.app"
    fi

    cd ..
    log_success "macOS 版本构建完成: bin/osx/release/RESP.app"
}

# 构建 Linux 版本
build_linux() {
    log_info "开始构建 Linux 版本 (版本: $VERSION)..."

    check_requirements "linux"

    cd src

    # 配置 qmake 项目
    log_info "配置 qmake 项目..."
    qmake "CONFIG+=release" "CONFIG-=debug" "DEFINES+=APP_VERSION=\\\"$VERSION\\\"" \
           "SYSTEM_LZ4=1" "SYSTEM_ZSTD=1" "SYSTEM_SNAPPY=1" "SYSTEM_BROTLI=1" \
           "CLEAN_RPATH=1"

    # 编译
    log_info "编译项目..."
    make -j$(nproc 2>/dev/null || echo 4)

    # 检查输出
    if [ ! -f "../bin/linux/release/resp" ]; then
        log_error "构建失败，未找到 resp"
        exit 1
    fi

    # 设置执行权限
    chmod +x ../bin/linux/release/resp

    cd ..
    log_success "Linux 版本构建完成: bin/linux/release/resp"
}

# 构建所有平台的测试版本
build_all() {
    log_info "构建所有平台版本..."

    # 保存当前平台
    CURRENT_PLATFORM=$(uname -s)

    case $CURRENT_PLATFORM in
        Darwin*)
            build_macos
            ;;
        Linux*)
            build_linux
            ;;
        CYGWIN*|MINGW*|MSYS*)
            build_windows
            ;;
        *)
            log_error "不支持的系统: $CURRENT_PLATFORM"
            exit 1
            ;;
    esac
}

# 显示使用帮助
show_help() {
    echo "RESP.app 构建脚本"
    echo ""
    echo "用法: $0 [选项] [版本号]"
    echo ""
    echo "选项:"
    echo "  windows    构建 Windows 版本"
    echo "  macos      构建 macOS 版本"
    echo "  linux      构建 Linux 版本"
    echo "  all        构建当前平台版本"
    echo "  clean      清理构建文件"
    echo "  help       显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 windows 2026.2.0"
    echo "  $0 macos 2026.2.0"
    echo "  $0 linux 2026.2.0"
    echo ""
    echo "环境变量:"
    echo "  VERSION    设置版本号 (默认: 2026.2.0-dev)"
    echo ""
    echo "下一步运行打包:"
    echo "  ./package.sh $0 $VERSION"
}

# 主函数
main() {
    log_info "RESP.app 构建脚本启动"
    log_info "版本号: $VERSION"

    case $1 in
        windows)
            clean_build
            build_windows
            ;;
        macos)
            clean_build
            build_macos
            ;;
        linux)
            clean_build
            build_linux
            ;;
        all)
            clean_build
            build_all
            ;;
        clean)
            clean_build
            ;;
        help|--help|-h)
            show_help
            ;;
        "")
            log_error "请指定构建平台"
            show_help
            exit 1
            ;;
        *)
            log_error "未知的选项: $1"
            show_help
            exit 1
            ;;
    esac

    if [ "$1" != "clean" ] && [ "$1" != "help" ] && [ "$1" != "--help" ] && [ "$1" != "-h" ]; then
        log_success "构建完成！"
        echo ""
        log_info "下一步运行打包:"
        echo "  ./package.sh $1 $VERSION"
    fi
}

# 执行主函数
main "$@"