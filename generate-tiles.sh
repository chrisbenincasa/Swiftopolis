#!/bin/sh

xcrun swiftc -framework Foundation -framework AppKit\
  -sdk $(xcrun --show-sdk-path --sdk macosx)\
  Libraries/*.swift Swiftopolis/ArrayExtensions.swift Swiftopolis/Option_Extensions.swift TileGenerator/*.swift -o TileGenerator/generator

./TileGenerator/generator $(echo $@ | tr '\n' ' ')
