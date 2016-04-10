BUILD_TOOL = xcodebuild
BUILD_SDK = $(shell xcrun --show-sdk-path --sdk macosx)
BUILD_ARGS = -workspace Swiftopolis-new.xcworkspace \
-scheme TileGenerator \
-sdk $(BUILD_SDK)

OUTPUT_PATH=./build/Swiftopolis-new/Build/Products/Debug

.PHONY: all build

all: clean build tiles

build:
	$(BUILD_TOOL) $(BUILD_ARGS)

clean:
	rm -rf TileGenerator/out/

tiles:
	$(OUTPUT_PATH)/TileGenerator --tile-size 3 --input-file Swiftopolis/tiles.json --output-dir build/ && \
    $(OUTPUT_PATH)/TileGenerator --tile-size 8 --input-file Swiftopolis/tiles.json --output-dir build/ && \
    $(OUTPUT_PATH)/TileGenerator --tile-size 16 --input-file Swiftopolis/tiles.json --output-dir build/
