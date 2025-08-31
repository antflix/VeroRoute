#!/bin/bash

# Test script to verify tutorials are properly configured
echo "VeroRoute Tutorials Test"
echo "========================"
echo

# Test 1: Check if app bundle exists
if [[ -e "VeroRoute.app" ]]; then
    echo "✅ VeroRoute.app exists"
else
    echo "❌ VeroRoute.app not found"
    exit 1
fi

# Test 2: Check if tutorials exist in Resources
if [[ -d "VeroRoute.app/Contents/Resources/tutorials" ]]; then
    TUTORIAL_COUNT=$(ls VeroRoute.app/Contents/Resources/tutorials/tutorial_*.vrt 2>/dev/null | wc -l)
    echo "✅ Found $TUTORIAL_COUNT tutorial files in Resources"
else
    echo "❌ Tutorials not found in Resources"
fi

# Test 3: Check if symlink structure exists
if [[ -L "VeroRoute.app/Contents/share/veroroute/tutorials" ]]; then
    echo "✅ Share tutorials symlink exists"
    SYMLINK_TARGET=$(readlink VeroRoute.app/Contents/share/veroroute/tutorials)
    echo "   → Points to: $SYMLINK_TARGET"
else
    echo "❌ Share tutorials symlink missing"
fi

# Test 4: Check if direct tutorials symlink exists  
if [[ -L "VeroRoute.app/tutorials" ]]; then
    echo "✅ Direct tutorials symlink exists"
    DIRECT_TARGET=$(readlink VeroRoute.app/tutorials)
    echo "   → Points to: $DIRECT_TARGET"
else
    echo "❌ Direct tutorials symlink missing"
fi

# Test 5: Check if tutorial files are accessible via symlinks
if [[ -f "VeroRoute.app/tutorials/tutorial_0.vrt" ]]; then
    echo "✅ Tutorial files accessible via direct symlink"
else
    echo "❌ Tutorial files not accessible via direct symlink"
fi

if [[ -f "VeroRoute.app/Contents/share/veroroute/tutorials/tutorial_0.vrt" ]]; then
    echo "✅ Tutorial files accessible via share symlink"
else
    echo "❌ Tutorial files not accessible via share symlink"
fi

echo
echo "Test complete. If all items show ✅, tutorials should work properly."