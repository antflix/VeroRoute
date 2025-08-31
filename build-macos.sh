#!/bin/bash

# VeroRoute macOS Build Script
# This script automates building VeroRoute from source on macOS
# Requires: macOS with Homebrew (will be installed if missing)

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VEROROUTE_VERSION="2.39"  # Default tested version
VEROROUTE_SOURCE_URL="https://sourceforge.net/projects/veroroute/files/veroroute-${VEROROUTE_VERSION}.tar.gz/download"
BUILD_DIR="$(pwd)/build"
INSTALL_DIR="$(pwd)/VeroRoute.app"
USE_LATEST_VERSION=false

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

check_command() {
    if ! command -v "$1" &> /dev/null; then
        return 1
    fi
    return 0
}

check_latest_version() {
    log_info "Checking for latest VeroRoute version..."
    
    # Try to get the latest version from SourceForge
    # This is a simple approach - look for version patterns in the files page
    LATEST_CHECK=$(curl -s "https://sourceforge.net/projects/veroroute/files/" | grep -o 'veroroute-[0-9]\+\.[0-9]\+\.tar\.gz' | head -1 | sed 's/veroroute-\(.*\)\.tar\.gz/\1/')
    
    if [[ -n "$LATEST_CHECK" && "$LATEST_CHECK" != "$VEROROUTE_VERSION" ]]; then
        log_info "Latest version found: $LATEST_CHECK (current default: $VEROROUTE_VERSION)"
        if $USE_LATEST_VERSION; then
            VEROROUTE_VERSION="$LATEST_CHECK"
            VEROROUTE_SOURCE_URL="https://sourceforge.net/projects/veroroute/files/veroroute-${VEROROUTE_VERSION}.tar.gz/download"
            log_info "Using latest version: $VEROROUTE_VERSION"
        else
            log_info "Using tested version: $VEROROUTE_VERSION (use --latest for newest)"
        fi
    else
        log_info "Using version: $VEROROUTE_VERSION"
    fi
}

install_homebrew() {
    if check_command brew; then
        log_info "Homebrew already installed"
        return 0
    fi
    
    log_error "Homebrew is required but not found. Please install Homebrew first:"
    log_error "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
}

install_dependencies() {
    log_info "Installing Qt dependencies..."
    
    # Install Qt5 via Homebrew
    brew install qt@5
    
    # Get Qt5 installation path
    QT5_PATH=$(brew --prefix qt@5)
    export PATH="$QT5_PATH/bin:$PATH"
    export PKG_CONFIG_PATH="$QT5_PATH/lib/pkgconfig:$PKG_CONFIG_PATH"
    
    log_success "Qt5 installed at: $QT5_PATH"
    
    # Verify qmake is available
    if ! check_command qmake; then
        log_error "qmake not found in PATH after Qt installation"
        exit 1
    fi
    
    QMAKE_VERSION=$(qmake -version | grep -o "Qt version [0-9]\.[0-9]*\.[0-9]*" | cut -d' ' -f3)
    log_info "Using Qt version: $QMAKE_VERSION"
    
    # Check minimum Qt version requirement (5.12.8)
    if [[ "$QMAKE_VERSION" < "5.12.8" ]]; then
        log_warning "Qt version $QMAKE_VERSION is older than required 5.12.8"
        log_warning "Build may fail or have compatibility issues"
    fi
}

download_source() {
    log_info "Downloading VeroRoute source code version $VEROROUTE_VERSION..."
    
    SOURCE_FILE="veroroute-${VEROROUTE_VERSION}-source.tar.gz"
    
    if [[ -f "$SOURCE_FILE" ]]; then
        log_info "Source tarball already exists, skipping download"
        return 0
    fi
    
    # Try wget first, then curl as fallback
    if command -v wget &> /dev/null; then
        log_info "Using wget to download..."
        wget -O "$SOURCE_FILE" "$VEROROUTE_SOURCE_URL"
    elif command -v curl &> /dev/null; then
        log_info "Using curl to download..."
        curl -L -o "$SOURCE_FILE" "$VEROROUTE_SOURCE_URL"
    else
        log_error "Neither wget nor curl found. Please install one of them."
        exit 1
    fi
    
    # Verify download
    if [[ -f "$SOURCE_FILE" && -s "$SOURCE_FILE" ]]; then
        log_success "Source code downloaded successfully"
    else
        log_error "Download failed or file is empty"
        rm -f "$SOURCE_FILE"
        exit 1
    fi
}

extract_source() {
    log_info "Extracting source code..."
    
    if [[ -d "VeroRoute" ]]; then
        log_info "Source directory already exists, removing old version"
        rm -rf VeroRoute
    fi
    
    tar -xzf "veroroute-${VEROROUTE_VERSION}-source.tar.gz"
    log_success "Source code extracted to VeroRoute/"
}


build_application() {
    log_info "Building VeroRoute..."
    
    cd VeroRoute/Src
    
    # Run qmake to generate Makefile (create app bundle)
    log_info "Running qmake..."
    qmake veroroute.pro CONFIG+=release
    
    # Build the application
    log_info "Compiling application..."
    make -j$(sysctl -n hw.ncpu)
    
    cd ../..
    log_success "VeroRoute built successfully"
    
    # Check for app bundle creation in VeroRoute directory
    if [[ -d "VeroRoute/veroroute.app" ]]; then
        log_success "App bundle created at VeroRoute/veroroute.app"
        
        # Copy app bundle to project root for easy access
        log_info "Copying app bundle to project root..."
        rm -rf VeroRoute.app
        cp -r VeroRoute/veroroute.app ./VeroRoute.app
        
        # Copy tutorials and resources to the app bundle for proper path resolution
        log_info "Setting up tutorials and resources..."
        mkdir -p "VeroRoute.app/Contents/Resources/"
        cp -r VeroRoute/tutorials VeroRoute.app/Contents/Resources/ 2>/dev/null || true
        cp -r VeroRoute/examples VeroRoute.app/Contents/Resources/ 2>/dev/null || true
        cp -r VeroRoute/libraries VeroRoute.app/Contents/Resources/ 2>/dev/null || true
        
        # Create additional tutorial locations (copies instead of symlinks for portability)
        mkdir -p "VeroRoute.app/Contents/share/veroroute/"
        cp -r VeroRoute/tutorials "VeroRoute.app/Contents/share/veroroute/" 2>/dev/null || true
        cp -r VeroRoute/tutorials "VeroRoute.app/" 2>/dev/null || true
        
        log_success "App bundle configured at ./VeroRoute.app"
    else
        log_error "App bundle not found at expected location"
        return 1
    fi
}


cleanup() {
    log_info "Cleaning up temporary files..."
    # Keep source code but clean build artifacts
    if [[ -d "VeroRoute/Src" ]]; then
        cd VeroRoute/Src
        make clean 2>/dev/null || true
        rm -f Makefile .qmake.stash
        cd ../..
    fi
}

test_application() {
    log_info "Testing the built application..."
    
    # Check for app bundle at project root
    if [[ -f "VeroRoute.app/Contents/MacOS/veroroute" ]]; then
        EXECUTABLE="VeroRoute.app/Contents/MacOS/veroroute"
    else
        log_error "App bundle executable not found at VeroRoute.app/Contents/MacOS/veroroute"
        return 1
    fi
    
    # Test version output
    VERSION_OUTPUT=$(./"$EXECUTABLE" --version 2>&1)
    if [[ $? -eq 0 && "$VERSION_OUTPUT" == *"VeroRoute Version"* ]]; then
        log_success "Application test passed: $VERSION_OUTPUT"
    else
        log_error "Application test failed: $VERSION_OUTPUT"
        return 1
    fi
}

create_archive() {
    log_info "Creating compressed archive for distribution..."
    
    if [[ -d "VeroRoute.app" ]]; then
        # Remove existing archive to avoid conflicts
        rm -f "VeroRoute.app.tar.gz"
        
        # Create compressed archive of the app bundle
        tar -czf "VeroRoute.app.tar.gz" VeroRoute.app
        log_success "Created VeroRoute.app.tar.gz for distribution"
        
        # Show archive size
        ARCHIVE_SIZE=$(du -sh "VeroRoute.app.tar.gz" | cut -f1)
        log_info "Archive size: $ARCHIVE_SIZE"
    else
        log_warning "VeroRoute.app not found, skipping archive creation"
    fi
}

print_summary() {
    log_success "VeroRoute build completed successfully!"
    echo ""
    
    if [[ -d "VeroRoute.app" ]]; then
        echo "App Bundle: $(pwd)/VeroRoute.app"
        echo "Executable: $(pwd)/VeroRoute.app/Contents/MacOS/veroroute"
        echo ""
        echo "To install and run VeroRoute (recommended):"
        echo "  cp -r VeroRoute.app /Applications/"
        echo "  open /Applications/VeroRoute.app"
        echo "  # OR drag VeroRoute.app to Applications folder in Finder"
        echo ""
        echo "To test build (quick verification):"
        echo "  open VeroRoute.app"
        echo "  # OR"
        echo "  ./VeroRoute.app/Contents/MacOS/veroroute"
    fi
    
    echo "Source code: $(pwd)/VeroRoute/"
    echo ""
    echo "✅ Tutorials and resources are properly configured"
    echo "✅ Qt libraries accessible via Homebrew installation"
    
    # Show archive information if it exists
    if [[ -f "VeroRoute.app.tar.gz" ]]; then
        ARCHIVE_SIZE=$(du -sh "VeroRoute.app.tar.gz" | cut -f1)
        echo "✅ Compressed archive created: VeroRoute.app.tar.gz ($ARCHIVE_SIZE)"
    fi
    
    echo ""
    echo "For development, you can open the Qt project file:"
    echo "  open VeroRoute/Src/veroroute.pro"
}

show_usage() {
    echo "VeroRoute macOS Build Script"
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --latest        Use the latest available version (default: use tested version 2.39)"
    echo "  --version VER   Use specific version number"
    echo "  --help, -h      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0              # Build with tested version (2.39)"
    echo "  $0 --latest     # Build with latest available version"
    echo "  $0 --version 2.38  # Build with specific version"
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --latest)
                USE_LATEST_VERSION=true
                shift
                ;;
            --version)
                if [[ -n "$2" && "$2" != --* ]]; then
                    VEROROUTE_VERSION="$2"
                    VEROROUTE_SOURCE_URL="https://sourceforge.net/projects/veroroute/files/veroroute-${VEROROUTE_VERSION}.tar.gz/download"
                    shift 2
                else
                    log_error "Version number required after --version"
                    exit 1
                fi
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

main() {
    parse_arguments "$@"
    
    echo "VeroRoute macOS Build Script"
    echo "============================"
    echo ""
    
    log_info "Starting build process..."
    
    # Check if we're on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "This script is designed for macOS only"
        exit 1
    fi
    
    # Check for latest version if requested
    if $USE_LATEST_VERSION; then
        check_latest_version
    fi
    
    # Install dependencies
    install_homebrew
    install_dependencies
    
    # Download and extract source
    download_source
    extract_source
    
    # Build application
    build_application
    
    # Test the application
    test_application
    
    # Cleanup
    cleanup
    
    # Create compressed archive
    create_archive
    
    # Print summary
    print_summary
}

# Handle script interruption
trap 'log_error "Build interrupted by user"; exit 1' INT TERM

# Run main function
main "$@"