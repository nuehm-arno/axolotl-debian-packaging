#########################################################################
# Mobian (aarch64) build and packaging recipe for Axolotl
# (c) Arno Nuehm, 2021
#########################################################################

.PHONY: check_platform dependencies build prebuild_package build_package install uninstall clean package_clean

all: check_platform dependencies clean build

GOPATH=$(shell go env GOPATH)
WORKDIR=$(GOPATH)/src/github.com/nanu-c/axolotl
VERSION=$(shell head -c 5 $(WORKDIR)/docs/CHANGELOG.md)

check_platform:
	@echo "Building Axolotl for Mobian (aarch64/amd64)"
  ifneq ($(shell uname),Linux)
	@echo "Platform unsupported - only available for Linux" && exit 1
  endif
  ifneq ($(shell uname -m),aarch64)
	@echo "Machine unsupported - only available for aarch64/arm64" && exit 1
  endif
  ifneq ($(shell which apt),/usr/bin/apt)
	@echo "OS unsupported - apt not found" && exit 1
  endif

dependencies:
	@echo "Installing dependencies for building Axolotl..."
	@sudo apt update
	@sudo apt install golang nodejs npm python

build:
	@echo "Downloading (go)..."
	@cd $(WORKDIR) && go mod download
	@echo "Installing (npm)..."
	@cd $(WORKDIR)/axolotl-web && npm install
	@echo "node-sass does not support aarch64/amd64 so it has to be rebuilt"
	@echo "Rebuilding of npm-sass..."
	@cd $(WORKDIR)/axolotl-web && npm rebuild node-sass
	@echo "Building (npm)..."
	@cd $(WORKDIR)/axolotl-web && npm run build
	@mkdir -p $(WORKDIR)/build/linux-arm64/axolotl-web
	@echo "Building (go)..."
	@cd $(WORKDIR) && env GOOS=linux GOARCH=arm64 go build -o build/linux-arm64/axolotl .
	@cp -r axolotl-web/dist build/linux-arm64/axolotl-web
	@cp -r guis build/linux-arm64
	@echo "Building complete."

prebuild_package: package_clean
	@echo "Prebuilding Debian package..."
	@cd $(WORKDIR) && wget https://github.com/nanu-c/axolotl/archive/main.tar.gz
	@mv $(WORKDIR)/main.tar.gz $(WORKDIR)/axolotl-$(VERSION).tar.gz
	@mkdir -p $(WORKDIR)/axolotl-$(VERSION)/axolotl
	@cp -r $(WORKDIR)/build/linux-arm64/* $(WORKDIR)/axolotl-$(VERSION)/axolotl
	@cp $(WORKDIR)/LICENSE $(WORKDIR)/axolotl-$(VERSION)/LICENSE
	@cd $(WORKDIR)/axolotl-$(VERSION) && debmake -e arno_nuehm@riseup.net -f "Arno Nuehm" -m
	@cp $(WORKDIR)/README.md $(WORKDIR)/axolotl-$(VERSION)/debian/README.Debian
	@mkdir -p $(WORKDIR)/axolotl-$(VERSION)/usr/share/icons/hicolor/128x128/apps
	@cp $(WORKDIR)/axolotl-$(VERSION)/axolotl/axolotl-web/dist/axolotl.png $(WORKDIR)/axolotl-$(VERSION)/usr/share/icons/hicolor/128x128/apps/axolotl.png
	@mkdir -p $(WORKDIR)/axolotl-$(VERSION)/usr/share/applications
	@cp $(WORKDIR)/deb/axolotl.desktop $(WORKDIR)/axolotl-$(VERSION)/usr/share/applications
	@cp $(WORKDIR)/deb/axolotl.install $(WORKDIR)/axolotl-$(VERSION)/debian
	@cp $(WORKDIR)/deb/postinst $(WORKDIR)/axolotl-$(VERSION)/debian
	@cp $(WORKDIR)/deb/postrm $(WORKDIR)/axolotl-$(VERSION)/debian

build_package:
	@cp $(WORKDIR)/deb/control $(WORKDIR)/axolotl-$(VERSION)/debian/control
	@nano $(WORKDIR)/axolotl-$(VERSION)/debian/changelog
	@nano $(WORKDIR)/axolotl-$(VERSION)/debian/copyright
	@cd $(WORKDIR)/axolotl-$(VERSION) && debuild -i -us -uc -b

install: uninstall
	@sudo mkdir -p /usr/share/axolotl
	@sudo cp -r $(WORKDIR)/axolotl-$(VERSION)/axolotl/* /usr/share/axolotl
	@sudo ln -sf /usr/share/axolotl/axolotl /usr/bin/axolotl
	@sudo cp $(WORKDIR)/deb/axolotl.desktop /usr/share/applications
	@sudo cp $(WORKDIR)/axolotl-$(VERSION)/axolotl/axolotl-web/dist/axolotl.png /usr/share/icons/hicolor/128x128/apps

uninstall:
	@sudo rm -rf /usr/share/axolotl
	@sudo rm -f /usr/bin/axolotl
	@sudo rm -f /usr/share/applications/axolotl.desktop
	@sudo rm -f /usr/share/icons/hicolor/128x128/apps/axolotl.png

clean:
	@rm -rf $(WORKDIR)/build

package_clean:
	@rm -rf $(WORKDIR)/axolotl-$(VERSION)
