GODOT_BIN ?= $(shell if command -v godot >/dev/null 2>&1; then command -v godot; elif command -v godot4 >/dev/null 2>&1; then command -v godot4; elif [ -x /Applications/Godot.app/Contents/MacOS/Godot ]; then printf '%s\n' /Applications/Godot.app/Contents/MacOS/Godot; fi)
IOS_EXPORT_PATH ?= build/ios/ToysSandbox

.PHONY: export-ios-xcode ios

export-ios-xcode:
	@if [ -z "$(GODOT_BIN)" ]; then \
		echo "Godot 4 editor binary not found. Set GODOT_BIN=/path/to/Godot."; \
		exit 1; \
	fi
	@mkdir -p "$(dir $(IOS_EXPORT_PATH))"
	"$(GODOT_BIN)" --headless --path . --export-debug "iOS" "$(IOS_EXPORT_PATH)"
	@echo "Generated Xcode project: $(IOS_EXPORT_PATH).xcodeproj"

ios:
	@$(MAKE) export-ios-xcode IOS_EXPORT_PATH=/private/tmp/ToysSandbox
	open /private/tmp/ToysSandbox.xcodeproj
