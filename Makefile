APP_NAME    := ClaudeBar
APP_BUNDLE  := build/$(APP_NAME).app
INSTALL_DIR := /Applications

.PHONY: app run install uninstall clean

app:
	swift build -c release
	rm -rf $(APP_BUNDLE)
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	cp .build/release/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	cp Resources/Info.plist $(APP_BUNDLE)/Contents/
	codesign --force --sign - $(APP_BUNDLE)

run: app
	-pkill -x $(APP_NAME)
	open $(APP_BUNDLE)

install: app
	-pkill -x $(APP_NAME)
	rm -rf $(INSTALL_DIR)/$(APP_NAME).app
	cp -R $(APP_BUNDLE) $(INSTALL_DIR)/
	open $(INSTALL_DIR)/$(APP_NAME).app

uninstall:
	-pkill -x $(APP_NAME)
	rm -rf $(INSTALL_DIR)/$(APP_NAME).app

clean:
	rm -rf .build build
