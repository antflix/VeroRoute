# VeroRoute for macOS

A native macOS build of VeroRoute, the cross-platform electronic design automation (EDA) software for creating Veroboard, Perfboard, and PCB layouts.

![VeroRoute](https://img.shields.io/badge/Version-2.39-blue) ![macOS](https://img.shields.io/badge/macOS-ARM64%20%7C%20Intel-green) ![Qt](https://img.shields.io/badge/Qt-5.12.8+-red)

## What is VeroRoute?

VeroRoute is a powerful PCB design tool that provides:
- **Interactive Auto-routing** for circuit boards
- **Connectivity Checking** to prevent short circuits
- **Netlist Import** from TinyCAD, gEDA, and KiCad
- **Gerber Export** for PCB manufacturing
- **Component Editor** for creating custom parts
- **Built-in Tutorials** for learning PCB design

**Note**: VeroRoute was originally available only for Windows and Linux. This project provides the native macOS build.

## Quick Start

### Option 1: Use Pre-built Binary (Recommended)

1. **Download the latest release** from [GitHub Releases](../../releases)
2. **Extract** the `VeroRoute.app` from the archive
3. **Install Qt5** (required dependency):
   ```bash
   # Install Homebrew if you don't have it
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   
   # Install Qt5
   brew install qt@5
   ```
4. **Install to Applications**:
   ```bash
   # Copy to Applications folder (recommended)
   cp -r VeroRoute.app /Applications/
   
   # Launch from Applications
   open /Applications/VeroRoute.app
   ```
   
   **Or using Finder**: Drag `VeroRoute.app` to your Applications folder, then launch from Launchpad or Applications folder.

### Option 2: Build from Source

```bash
# Clone or download this repository
# Ensure you have Homebrew installed, then run:

./build-macos.sh
```

This script will:
1. Install Qt5 via Homebrew
2. Download VeroRoute source code
3. Compile for your Mac (ARM64 or Intel)
4. Create a native macOS application bundle

### Launch VeroRoute

**Normal Usage** (recommended):
```bash
# Install to Applications folder
cp -r VeroRoute.app /Applications/
open /Applications/VeroRoute.app
```

**Or using Finder**: Drag `VeroRoute.app` to your Applications folder, then launch from Launchpad or Applications folder.

**Quick Test** (to verify build was successful):
```bash
# Test directly from build directory
open VeroRoute.app

# Or use the launcher script
./run-veroroute.sh
```

## System Requirements

- **macOS**: 10.15 (Catalina) or later
- **Architecture**: Apple Silicon (M1/M2) or Intel
- **Homebrew**: For dependency management
- **Disk Space**: ~50MB for application, ~200MB during build

## Features

### Supported Board Types
- **Veroboard**: Stripboard with copper strips
- **Perfboard**: Prototyping board with holes
- **PCB**: Printed circuit boards

### Import/Export Formats
- **Import**: TinyCAD (.dsn), gEDA (.sch), KiCad netlists
- **Export**: Gerber files, PNG images, VRT project files

### Design Tools
- Component placement and routing
- Ground fill for PCB designs  
- Layer management (1 or 2 layers)
- Design rule checking
- Bill of materials (BOM) generation

## Getting Started

1. **Launch VeroRoute** using the app bundle
2. **Start the Tutorial**: Help → Tutorial → Begin Tutorial
3. **Try Examples**: File → Open → Browse examples folder
4. **Create New Design**: File → New → Choose board type

## Project Structure

```
veroroute/
├── README.md                    # This file
├── CLAUDE.md                    # Developer/AI assistant guide
├── build-macos.sh              # Automated build script
├── run-veroroute.sh            # Application launcher
├── cleanup.sh                  # Clean build artifacts
├── test-tutorials.sh           # Test tutorial configuration
├── make-veroroute-portable.sh  # Experimental portability script
├── VeroRoute.app/              # Native macOS application (after build)
└── VeroRoute/                  # Source code (after build)
```

## Original Project

This is a macOS port of VeroRoute by Alex Lawrow:
- **Original Project**: https://sourceforge.net/projects/veroroute/
- **License**: GNU General Public License v3.0
- **Author**: Alex Lawrow (dralx@users.sourceforge.net)

## Building from Source

See `CLAUDE.md` for detailed build instructions, development setup, and Qt project configuration.

## Troubleshooting

### Application Won't Start
```bash
# Check if Qt5 is installed
brew list qt@5

# Rebuild the application
./build-macos.sh
```

### Missing Tutorials Error
The build script automatically bundles tutorials. If you see this error, try:
```bash
# Rebuild with fresh download
rm -rf VeroRoute VeroRoute.app
./build-macos.sh
```

### Performance Issues
- Ensure you're running the native version (not through Rosetta)
- Close other resource-intensive applications
- Check Activity Monitor for CPU/memory usage

## Contributing

This project focuses on providing macOS compatibility for VeroRoute. For core VeroRoute features and bug reports, please contact the original project.

For macOS-specific build issues:
- Check existing issues
- Include system information (macOS version, chip type)
- Provide build logs if applicable

## License

GNU General Public License v3.0 - Same as original VeroRoute project.

---

**Disclaimer**: This is an unofficial macOS port. For official support, please refer to the original VeroRoute project on SourceForge.
