#!/bin/sh

SOURCES="Libraries/*.swift Swiftopolis/ArrayExtensions.swift Swiftopolis/Option_Extensions.swift TileGenerator/*.swift"

xcrun swiftc -framework Foundation -framework AppKit\
  -sdk $(xcrun --show-sdk-path --sdk macosx)\
  $SOURCES -o TileGenerator/generator.o

./TileGenerator/generator.o $(echo $@ | tr '\n' ' ')
