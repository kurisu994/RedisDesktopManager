#!/bin/bash

# RESP.app 打包脚本
# 支持 Windows, macOS, Linux 三个平台的打包
#
# 用法: ./package.sh [windows|macos|linux] [版本号]

set -e  # 遇到错误时退出

# 默认版本号
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

# 检查构建结果
check_build() {
    local platform=$1
    log_info "检查 $platform 构建结果..."

    case $platform in
        windows)
                if [ ! -f "bin/windows/release/resp.exe" ]; then
                        log_error "未找到 Windows 构建结果: bin/windows/release/resp.exe"
                        log_info "请先运行: ./build.sh windows $VERSION"
                        exit 1
                fi
                ;;
        macos)
                if [ ! -d "bin/osx/release/RESP.app" ]; then
                        log_error "未找到 macOS 构建结果: bin/osx/release/RESP.app"
                        log_info "请先运行: ./build.sh macos $VERSION"
                        exit 1
                fi
                ;;
        linux)
                if [ ! -f "bin/linux/release/resp" ]; then
                        log_error "未找到 Linux 构建结果: bin/linux/release/resp"
                        log_info "请先运行: ./build.sh linux $VERSION"
                        exit 1
                fi
                ;;
    esac

    log_success "$platform 构建结果检查通过"
}

# 创建输出目录
create_output_dir() {
    OUTPUT_DIR="packages/$VERSION"
    mkdir -p "$OUTPUT_DIR"
    log_info "输出目录: $OUTPUT_DIR"
}

# 打包 Windows 版本
package_windows() {
    log_info "开始打包 Windows 版本 (版本: $VERSION)..."

    check_build "windows"
    create_output_dir

    # 检查 NSIS
    if ! command -v makensis &> /dev/null; then
        log_error "makensis 未找到，请安装 NSIS"
        log_info "下载地址: https://nsis.sourceforge.io/"
        exit 1
    fi

    cd build/windows/installer

    # 更新版本号
    log_info "更新 NSIS 版本号..."
    sed -i.bak "s/resp-${VERSION}.exe/resp-$VERSION.exe/g" installer.nsi
    sed -i.bak "s/\${VERSION}/$VERSION/g" installer.nsi

    # 检查必要的文件
    if [ ! -f "../../bin/windows/release/resp.exe" ]; then
        log_error "未找到 resp.exe"
        exit 1
    fi

    # 复制构建结果到临时目录
    log_info "准备打包文件..."
    mkdir -p tmp
    cp -r resources tmp/
    cp ../../bin/windows/release/resp.exe tmp/
    cp -r ../../bin/windows/release/lib tmp/ 2>/dev/null || true

    # 运行 NSIS
    log_info "运行 NSIS 打包..."
    makensis -DVERSION="$VERSION" installer.nsi

    # 检查输出
    if [ -f "resp-$VERSION.exe" ]; then
        mv "resp-$VERSION.exe" "../../../$OUTPUT_DIR/"
        log_success "Windows 安装包创建成功: packages/$VERSION/resp-$VERSION.exe"
    else
        log_error "Windows 安装包创建失败"
        exit 1
    fi

    # 清理
    rm -rf tmp installer.nsi.bak
    cd ../..
}

# 打包 macOS 版本
package_macos() {
    log_info "开始打包 macOS 版本 (版本: $VERSION)..."

    check_build "macos"
    create_output_dir

    # 检查 macdeployqt
    if ! command -v macdeployqt &> /dev/null; then
        log_error "macdeployqt 未找到，请安装 Qt 工具"
        exit 1
    fi

    # 检查 hdiutil
    if ! command -v hdiutil &> /dev/null; then
        log_error "hdiutil 未找到，请确保在 macOS 上运行"
        exit 1
    fi

    # 复制应用程序包
    APP_BUNDLE="bin/osx/release/RESP.app"
    if [ ! -d "$APP_BUNDLE" ]; then
        log_error "未找到应用程序包: $APP_BUNDLE"
        exit 1
    fi

    # 部署 Qt 框架
    log_info "部署 Qt 框架..."
    macdeployqt "$APP_BUNDLE" -qmldir=src/qml

    # 更新 Info.plist（需在代码签名之前完成）
    if [ -f "src/resources/Info.plist.sample" ]; then
        log_info "更新 Info.plist..."
        cp "src/resources/Info.plist.sample" "$APP_BUNDLE/Contents/Info.plist"
        sed -i '' "s/0.0.0/$VERSION/g" "$APP_BUNDLE/Contents/Info.plist"
    fi

    # Ad-hoc 代码签名（macdeployqt 修改二进制后需要重新签名）
    log_info "对应用程序进行代码签名..."
    # 先签名所有 Frameworks 和插件
    find "$APP_BUNDLE/Contents/Frameworks" -name "*.dylib" -o -name "*.framework" -type d | while read -r item; do
        codesign --force --sign - "$item" 2>/dev/null || true
    done
    find "$APP_BUNDLE/Contents/PlugIns" -name "*.dylib" | while read -r item; do
        codesign --force --sign - "$item" 2>/dev/null || true
    done
    # 最后签名整个 app bundle
    codesign --force --deep --sign - "$APP_BUNDLE"
    log_success "代码签名完成"

    # 创建临时 DMG 目录
    DMG_TEMP="dmg_temp"
    rm -rf "$DMG_TEMP"
    mkdir "$DMG_TEMP"

    # 复制应用程序和链接
    log_info "准备 DMG 内容..."
    cp -R "$APP_BUNDLE" "$DMG_TEMP/"

    # 创建 Applications 链接
    ln -s /Applications "$DMG_TEMP/Applications"

    # 可选：添加背景图片和图标位置
    if [ -f "build/dmg_background.png" ]; then
        mkdir -p "$DMG_TEMP/.background"
        cp "build/dmg_background.png" "$DMG_TEMP/.background/"
    fi

    if [ -f "build/dmg_icon.icns" ]; then
        cp "build/dmg_icon.icns" "$DMG_TEMP/.VolumeIcon.icns"
    fi

    # 创建 DMG
    log_info "创建 DMG 镜像..."
    DMG_NAME="RESP-$VERSION.dmg"
    hdiutil create -volname "RESP" \
                 -srcfolder "$DMG_TEMP" \
                 -ov -format UDZO \
                 -fs HFS+ \
                 "$OUTPUT_DIR/$DMG_NAME"

    # 清理临时文件
    rm -rf "$DMG_TEMP"

    log_success "macOS DMG 创建成功: packages/$VERSION/$DMG_NAME"
}

# 打包 Linux 版本
package_linux() {
    log_info "开始打包 Linux 版本 (版本: $VERSION)..."

    check_build "linux"
    create_output_dir

    # 设置变量
    APP_NAME="resp"
    INSTALL_PATH="/opt/resp_app"
    APP_BINARY="bin/linux/release/resp"

    # 检查构建结果
    if [ ! -f "$APP_BINARY" ]; then
        log_error "未找到应用程序二进制: $APP_BINARY"
        exit 1
    fi

    # 创建临时目录
    TMP_DIR="tmp_linux_package"
    rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR/$INSTALL_PATH"

    # 复制应用程序
    log_info "复制应用程序文件..."
    cp "$APP_BINARY" "$TMP_DIR/$INSTALL_PATH/"
    chmod +x "$TMP_DIR/$INSTALL_PATH/resp"

    # 复制库文件
    if [ -d "lib" ]; then
        mkdir -p "$TMP_DIR/$INSTALL_PATH/lib"
        cp -r lib/* "$TMP_DIR/$INSTALL_PATH/lib/"
    fi

    # 复制资源文件
    if [ -f "src/resources/qt.conf" ]; then
        mkdir -p "$TMP_DIR/$INSTALL_PATH"
        cp "src/resources/qt.conf" "$TMP_DIR/$INSTALL_PATH/"
    fi

    # 复制桌面文件
    log_info "创建桌面集成文件..."
    if [ -f "src/resources/resp.desktop" ]; then
        mkdir -p "$TMP_DIR/usr/share/applications"
        cp "src/resources/resp.desktop" "$TMP_DIR/usr/share/applications/"
        sed -i "s/Version=.*/Version=$VERSION/g" "$TMP_DIR/usr/share/applications/resp.desktop"
    fi

    # 复制图标
    if [ -f "src/resources/images/resp.png" ]; then
        mkdir -p "$TMP_DIR/usr/share/pixmaps"
        cp "src/resources/images/resp.png" "$TMP_DIR/usr/share/pixmaps/"
    fi

    # 创建安装脚本
    log_info "创建安装脚本..."
    cat > "$TMP_DIR/install.sh" << 'EOF'
#!/bin/bash

set -e

# 检查权限
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 运行安装脚本"
    exit 1
fi

echo "安装 RESP.app..."

# 复制应用程序文件
cp -r /opt/resp_app /opt/ 2>/dev/null || true
cp -r * /

# 更新桌面数据库
update-desktop-database /usr/share/applications/ 2>/dev/null || true

echo "安装完成！"
echo "启动应用程序: resp"
echo "或者从应用程序菜单启动 RESP.app"
EOF

    chmod +x "$TMP_DIR/install.sh"

    # 创建卸载脚本
    log_info "创建卸载脚本..."
    cat > "$TMP_DIR/uninstall.sh" << 'EOF'
#!/bin/bash

set -e

# 检查权限
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 运行卸载脚本"
    exit 1
fi

echo "卸载 RESP.app..."

# 删除应用程序文件
rm -rf /opt/resp_app

# 删除桌面文件和图标
rm -f /usr/share/applications/resp.desktop
rm -f /usr/share/pixmaps/resp.png

# 更新桌面数据库
update-desktop-database /usr/share/applications/ 2>/dev/null || true

echo "卸载完成！"
EOF

    chmod +x "$TMP_DIR/uninstall.sh"

    # 创建 tar.gz 包
    log_info "创建压缩包..."
    ARCHIVE_NAME="RESP-$VERSION-linux-x86_64.tar.gz"
    cd "$TMP_DIR"
    tar -czf "../packages/$VERSION/$ARCHIVE_NAME" .
    cd ..

    # 清理临时文件
    rm -rf "$TMP_DIR"

    log_success "Linux 包创建成功: packages/$VERSION/$ARCHIVE_NAME"

    # 可选：创建 Debian 包
    if command -v dpkg-deb &> /dev/null; then
        log_info "创建 Debian 包..."
        create_debian_package "$VERSION"
    fi
}

# 创建 Debian 包
create_debian_package() {
    local version=$1
    local pkg_name="resp-app"
    local pkg_version=$(echo "$version" | sed 's/-/~/g')  # 转换版本格式

    DEBIAN_DIR="tmp_debian"
    rm -rf "$DEBIAN_DIR"

    # 创建 DEBIAN 目录结构
    mkdir -p "$DEBIAN_DIR/DEBIAN"
    mkdir -p "$DEBIAN_DIR/opt/resp_app"
    mkdir -p "$DEBIAN_DIR/usr/share/applications"
    mkdir -p "$DEBIAN_DIR/usr/share/pixmaps"

    # 复制文件
    cp "bin/linux/release/resp" "$DEBIAN_DIR/opt/resp_app/"
    chmod +x "$DEBIAN_DIR/opt/resp_app/resp"

    if [ -d "lib" ]; then
        mkdir -p "$DEBIAN_DIR/opt/resp_app/lib"
        cp -r lib/* "$DEBIAN_DIR/opt/resp_app/lib/"
    fi

    if [ -f "src/resources/qt.conf" ]; then
        cp "src/resources/qt.conf" "$DEBIAN_DIR/opt/resp_app/"
    fi

    if [ -f "src/resources/resp.desktop" ]; then
        cp "src/resources/resp.desktop" "$DEBIAN_DIR/usr/share/applications/"
    fi

    if [ -f "src/resources/images/resp.png" ]; then
        cp "src/resources/images/resp.png" "$DEBIAN_DIR/usr/share/pixmaps/"
    fi

    # 创建 control 文件
    cat > "$DEBIAN_DIR/DEBIAN/control" << EOF
Package: $pkg_name
Version: $pkg_version
Section: devel
Priority: optional
Architecture: amd64
Depends: libqt5charts5, libqt5gui5, libqt5core5a, libqt5qml5, libqt5quick5, libqt5widgets5, libqt5network5, libqt5concurrent5, libqt5svg5
Maintainer: Igor Malinovskiy <support@resp.app>
Description: Open source Developer GUI for Redis®
 RESP.app is a powerful, cross-platform Redis database management tool.
 It provides an intuitive interface for managing Redis data structures,
 including keys, strings, hashes, lists, sets, sorted sets, and streams.
Homepage: https://resp.app
EOF

    # 计算安装大小
    local size=$(du -s "$DEBIAN_DIR" | cut -f1)
    echo "Installed-Size: $size" >> "$DEBIAN_DIR/DEBIAN/control"

    # 构建 Debian 包
    local deb_name="resp-app_${pkg_version}_amd64.deb"
    dpkg-deb --build "$DEBIAN_DIR" "$OUTPUT_DIR/$deb_name"

    # 清理
    rm -rf "$DEBIAN_DIR"

    log_success "Debian 包创建成功: packages/$VERSION/$deb_name"
}

# 创建所有平台包
package_all() {
    log_info "创建所有平台包..."

    # 保存当前平台
    CURRENT_PLATFORM=$(uname -s)

    case $CURRENT_PLATFORM in
        Darwin*)
                if [ -d "bin/osx/release/RESP.app" ]; then
                    package_macos
                else
                    log_warning "未找到 macOS 构建结果，跳过 macOS 打包"
                fi
                ;;
        Linux*)
                if [ -f "bin/linux/release/resp" ]; then
                    package_linux
                else
                    log_warning "未找到 Linux 构建结果，跳过 Linux 打包"
                fi
                ;;
        CYGWIN*|MINGW*|MSYS*)
                if [ -f "bin/windows/release/resp.exe" ]; then
                    package_windows
                else
                    log_warning "未找到 Windows 构建结果，跳过 Windows 打包"
                fi
                ;;
        *)
                log_error "不支持的系统: $CURRENT_PLATFORM"
                exit 1
                ;;
    esac
}

# 显示使用帮助
show_help() {
    echo "RESP.app 打包脚本"
    echo ""
    echo "用法: $0 [选项] [版本号]"
    echo ""
    echo "选项:"
    echo "  windows    打包 Windows 版本 (NSIS)"
    echo "  macos      打包 macOS 版本 (DMG)"
    echo "  linux      打包 Linux 版本 (TAR.GZ + DEB)"
    echo "  all        打包所有平台版本"
    echo "  clean      清理打包文件"
    echo "  help       显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 windows 2024.1.0"
    echo "  $0 macos 2024.1.0"
    echo "  $0 linux 2024.1.0"
    echo "  $0 all 2024.1.0"
    echo ""
    echo "环境变量:"
    echo "  VERSION    设置版本号 (默认: 2024.1.0-dev)"
    echo ""
    echo "输出目录:"
    echo "  packages/VERSION/"
    echo ""
}

# 清理打包文件
clean_packages() {
    log_info "清理打包文件..."
    rm -rf packages/
    rm -rf dmg_temp/
    rm -rf tmp_linux_package/
    rm -rf tmp_debian/
    rm -rf tmp/
    log_success "清理完成"
}

# 主函数
main() {
    log_info "RESP.app 打包脚本启动"
    log_info "版本号: $VERSION"

    case $1 in
        windows)
                package_windows
                ;;
        macos)
                package_macos
                ;;
        linux)
                package_linux
                ;;
        all)
                package_all
                ;;
        clean)
                clean_packages
                ;;
        help|--help|-h)
                show_help
                ;;
        "")
                log_error "请指定打包平台"
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
        log_success "打包完成！"
        echo ""
        log_info "输出文件位置: packages/$VERSION/"
        ls -la "packages/$VERSION/"
    fi
}

# 执行主函数
main "$@"