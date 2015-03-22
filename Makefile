BUILD_TOOL = xcodebuild
BUILD_SDK = $(shell xcrun --show-sdk-path --sdk macosx)
BUILD_ARGS = -target TileGenerator -sdk $(BUILD_SDK) CONFIGURATION_BUILD_DIR='TileGenerator/out/'

.PHONY: all build

all: clean build tiles

build:
	$(BUILD_TOOL) $(BUILD_ARGS)

clean:
	rm -rf TileGenerator/out/

tiles:
	./TileGenerator/out/TileGenerator --tile-size 3 --input-file Swiftopolis/tiles.json --output-dir build/ && \
    ./TileGenerator/out/TileGenerator --tile-size 8 --input-file Swiftopolis/tiles.json --output-dir build/ && \
    ./TileGenerator/out/TileGenerator --tile-size 16 --input-file Swiftopolis/tiles.json --output-dir build/
