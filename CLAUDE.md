# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**VeroRoute** is a cross-platform electronic design automation (EDA) software for creating Veroboard, Perfboard, and PCB layouts. This repository contains the source code and build tools for compiling VeroRoute natively on macOS.

- **Version**: 2.39
- **License**: GNU General Public License v3.0
- **Language**: C++
- **Framework**: Qt (5.12.8 or later)
- **Original Project**: https://sourceforge.net/projects/veroroute/

## Quick Start - Automated Build

```bash
# One-command build (recommended)
./build-macos.sh

# Install to Applications (recommended)
cp -r VeroRoute.app /Applications/
open /Applications/VeroRoute.app
# OR drag VeroRoute.app to Applications folder in Finder

# OR test directly (quick verification)
open VeroRoute.app
```

This script handles everything: dependency installation, source download, compilation, and app bundle creation with proper resource paths.

## Manual Build Process

### Prerequisites

1. **macOS**: 10.15 (Catalina) or later
2. **Homebrew**: Package manager for macOS
3. **Qt 5**: Cross-platform framework (≥5.12.8)
4. **Xcode Command Line Tools**: For compilation

### Install Dependencies

```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Qt5
brew install qt@5

# Add Qt5 to PATH
export PATH="$(brew --prefix qt@5)/bin:$PATH"
```

### Download and Build

```bash
# Download source
wget -O veroroute-2.39-source.tar.gz "https://sourceforge.net/projects/veroroute/files/veroroute-2.39.tar.gz/download"
tar -xzf veroroute-2.39-source.tar.gz

# Build
cd VeroRoute/Src
qmake veroroute.pro CONFIG+=release
make -j$(sysctl -n hw.ncpu)
```

### Run Application

```bash
# From source directory
cd VeroRoute
./veroroute

# Or use the generated app bundle
open VeroRoute.app
```

## Project Structure

```
veroroute/
├── build-macos.sh              # Automated build script for macOS
├── VeroRoute/                  # Source code (extracted from tarball)
│   ├── Src/                   # Main source directory
│   │   ├── veroroute.pro      # Qt project file
│   │   ├── main.cpp           # Application entry point
│   │   ├── mainwindow.cpp     # Main GUI window
│   │   ├── Board.cpp          # PCB/board logic
│   │   └── *.ui               # Qt Designer UI files
│   ├── tutorials/             # Built-in tutorial files (*.vrt)
│   ├── examples/              # Example circuit files
│   ├── libraries/             # Component libraries (TinyCAD/gEDA)
│   └── README.txt             # Original project documentation
└── VeroRoute.app/             # Generated macOS application bundle
```

## Development Environment

### Qt Creator IDE

For active development, use Qt Creator:

```bash
# Install Qt Creator
brew install --cask qt-creator

# Open project
open VeroRoute/Src/veroroute.pro
```

### Build Configuration

The Qt project file (`veroroute.pro`) includes:
- **Target**: `veroroute` executable
- **Qt Modules**: `core`, `gui`, `widgets`, `network`
- **C++ Standard**: C++11
- **Optimization**: Release builds use full optimization
- **Platform**: Cross-platform (Windows/Linux/macOS)

### Key Build Settings

```qmake
QT += core gui network widgets
CONFIG += c++11 optimize_full
TARGET = veroroute
TEMPLATE = app
DESTDIR = ..  # Executable created outside Src/ folder
```

## macOS-Specific Features

### Application Bundle

The build script creates a proper macOS `.app` bundle with:
- **Executable**: `VeroRoute.app/Contents/MacOS/VeroRoute`
- **Resources**: Tutorials, examples, libraries bundled inside
- **Qt Libraries**: Bundled using `macdeployqt`
- **Icon**: Native `.icns` icon file
- **Info.plist**: Native macOS application metadata

### File Associations

The app bundle supports:
- **File Extension**: `.vrt` (VeroRoute files)
- **Document Type**: VeroRoute circuit files
- **Role**: Editor (can create and edit)

## Common Development Tasks

### Clean Build

```bash
cd VeroRoute/Src
make clean
rm -f Makefile .qmake.stash
qmake veroroute.pro CONFIG+=release
make
```

### Debug Build

```bash
cd VeroRoute/Src
qmake veroroute.pro CONFIG+=debug
make
```

### Update Qt Dependencies

```bash
brew upgrade qt@5
# May require rebuilding application
```

## Architecture

### Core Components

- **Board**: PCB layout engine (`Board.cpp/.h`)
- **Component**: Electronic component system (`Component.cpp/.h`)
- **GuiControl**: User interface controller (`GuiControl.cpp/.h`)
- **GWriter**: Gerber file export (`GWriter.cpp/.h`)
- **CompTypes**: Component type definitions (`CompTypes.cpp/.h`)

### Key Features

1. **Interactive Routing**: Auto-routing with manual override
2. **Multi-Format Import**: TinyCAD, gEDA, KiCad netlists
3. **Export Formats**: Gerber files for PCB manufacturing
4. **Component Editor**: Built-in component creation
5. **Tutorial System**: Interactive learning modules

### Qt Framework Usage

- **Widgets**: Traditional desktop GUI (not QML)
- **Networking**: For potential future cloud features
- **Graphics**: 2D rendering for PCB visualization
- **File I/O**: Project persistence and import/export

## Build Results

After successful build, you'll have:

- **VeroRoute.app**: Native macOS application bundle
- **VeroRoute/**: Source code directory with built executable
- **build-macos.sh**: Repeatable build script
- **run-veroroute.sh**: Simple launcher script

The app bundle includes:
- Executable at `VeroRoute.app/Contents/MacOS/veroroute`
- Tutorials at `VeroRoute.app/Contents/Resources/tutorials/`
- Examples and libraries bundled inside
- Proper symlinks for resource discovery

## Troubleshooting

### Qt Version Issues

If build fails with Qt version errors:
```bash
# Check Qt version
qmake -version

# Ensure minimum version 5.12.8
brew install qt@5
```

### Missing Dependencies

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify toolchain
gcc --version
make --version
```

### Runtime Issues

- **Missing resources**: Ensure tutorials/examples are in app bundle
- **Permission errors**: Verify app bundle has execute permissions

## Original Documentation

- **README**: `VeroRoute/README.txt`
- **Changelog**: `VeroRoute/CHANGELOG.txt`
- **License**: `VeroRoute/licenses/license_GPLv3.txt`

## Project Goals

This repository aims to:
1. **Enable macOS builds**: Fill gap in official platform support
2. **Preserve compatibility**: Maintain cross-platform nature
3. **Automate builds**: Reduce setup friction with build script
4. **Native integration**: Create proper macOS app experience
