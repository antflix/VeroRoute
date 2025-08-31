#!/bin/bash

# VeroRoute macOS Cleanup Script
# This script removes all build artifacts and downloaded files
# Use this to start fresh or clean up after testing

set -e

# Colors for output
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

confirm_cleanup() {
    echo "This will remove the following files and directories:"
    echo ""
    
    # List what will be removed
    [[ -d "VeroRoute" ]] && echo "  - VeroRoute/ (source code directory)"
    [[ -d "VeroRoute.app" ]] && echo "  - VeroRoute.app (application bundle)"
    [[ -f "veroroute-2.39-source.tar.gz" ]] && echo "  - veroroute-2.39-source.tar.gz (source archive)"
    [[ -f "veroroute-source.zip" ]] && echo "  - veroroute-source.zip (Windows binary archive)"
    [[ -d "VeroRoute_V239_Windows_32bit" ]] && echo "  - VeroRoute_V239_Windows_32bit/ (Windows files)"
    
    echo ""
    echo "The following files will be kept:"
    echo "  - build-macos.sh (build script)"
    echo "  - cleanup.sh (this script)"
    echo "  - run-veroroute.sh (launcher script)"
    echo "  - README.md (user documentation)"
    echo "  - CLAUDE.md (developer documentation)"
    echo ""
    
    read -p "Do you want to continue? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Cleanup cancelled"
        exit 0
    fi
}

cleanup_files() {
    log_info "Starting cleanup..."
    
    # Remove build artifacts and downloads
    if [[ -d "VeroRoute" ]]; then
        log_info "Removing VeroRoute source directory..."
        rm -rf VeroRoute
        log_success "VeroRoute source directory removed"
    fi
    
    if [[ -d "VeroRoute.app" ]]; then
        log_info "Removing VeroRoute application bundle..."
        rm -rf VeroRoute.app
        log_success "VeroRoute application bundle removed"
    fi
    
    if [[ -f "veroroute-2.39-source.tar.gz" ]]; then
        log_info "Removing source tarball..."
        rm -f veroroute-2.39-source.tar.gz
        log_success "Source tarball removed"
    fi
    
    if [[ -f "veroroute-source.zip" ]]; then
        log_info "Removing Windows binary archive..."
        rm -f veroroute-source.zip
        log_success "Windows binary archive removed"
    fi
    
    if [[ -d "VeroRoute_V239_Windows_32bit" ]]; then
        log_info "Removing Windows files directory..."
        rm -rf VeroRoute_V239_Windows_32bit
        log_success "Windows files directory removed"
    fi
    
    # Remove any potential leftover build files
    find . -name "*.o" -delete 2>/dev/null || true
    find . -name "Makefile" -not -path "./VeroRoute/*" -delete 2>/dev/null || true
    find . -name ".qmake.stash" -delete 2>/dev/null || true
    find . -name "moc_*" -delete 2>/dev/null || true
    find . -name "ui_*" -delete 2>/dev/null || true
    find . -name "qrc_*" -delete 2>/dev/null || true
    
    log_success "Cleanup completed successfully!"
}

print_summary() {
    echo ""
    echo "Cleanup Summary:"
    echo "================"
    echo ""
    echo "✅ All build artifacts removed"
    echo "✅ Downloaded source files removed" 
    echo "✅ Application bundle removed"
    echo "✅ Temporary build files cleaned"
    echo ""
    echo "To rebuild VeroRoute:"
    echo "  ./build-macos.sh"
    echo ""
    echo "Remaining files:"
    ls -la *.sh *.md 2>/dev/null || echo "  (script and documentation files)"
}

main() {
    echo "VeroRoute macOS Cleanup Script"
    echo "=============================="
    echo ""
    
    # Check if we're in the right directory
    if [[ ! -f "build-macos.sh" ]]; then
        log_error "build-macos.sh not found. Are you in the correct directory?"
        exit 1
    fi
    
    # Check if there's anything to clean
    if [[ ! -d "VeroRoute" && ! -d "VeroRoute.app" && ! -f "veroroute-2.39-source.tar.gz" ]]; then
        log_info "No build artifacts found. Directory is already clean."
        exit 0
    fi
    
    # Confirm before cleanup
    confirm_cleanup
    
    # Perform cleanup
    cleanup_files
    
    # Print summary
    print_summary
}

# Handle script interruption
trap 'log_error "Cleanup interrupted by user"; exit 1' INT TERM

# Run main function
main "$@"