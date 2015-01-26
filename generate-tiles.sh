#!/bin/sh

SOURCES="Libraries/*.swift Swiftopolis/ArrayExtensions.swift Swiftopolis/Option_Extensions.swift TileGenerator/*.swift"

#xcrun swiftc -framework Foundation -framework AppKit\
#  -sdk $(xcrun --show-sdk-path --sdk macosx)\
#  $SOURCES -o TileGenerator/generator.o

#./TileGenerator/generator.o --tile-size 3 --input-file Swiftopolis/tiles.json --output-dir build/
#./TileGenerator/generator.o --tile-size 8 --input-file Swiftopolis/tiles.json --output-dir build/
#./TileGenerator/generator.o --tile-size 16 --input-file Swiftopolis/tiles.json --output-dir build/
