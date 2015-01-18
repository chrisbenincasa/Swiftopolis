#!/bin/sh

xcrun swiftc -framework Foundation -framework AppKit\
  -sdk $(xcrun --show-sdk-path --sdk macosx)\
  Libraries/*.swift TileGenerator/*.swift -o TileGenerator/generator

./TileGenerator/generator $@
