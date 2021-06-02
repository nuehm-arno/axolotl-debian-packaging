#########################################################################
# Mobian (arm64/aarch64) building and packaging recipe for Axolotl
# (c) Arno Nuehm, 2021
# Please get the source via
#  go get -d -u github.com/nanu-c/axolotl/
# and execute "make" commands in the repository folder
#########################################################################

.PHONY: check-platform-arm64 dependencies-arm64 build-arm64 prebuild-package-arm64 build-package-arm64 install-arm64 uninstall-arm64 clean-arm64 package-clean-arm64

all: check-platform-arm64 dependencies-arm64 clean-arm64 build-arm64

GOPATH := $(shell go env GOPATH)
WORKDIR := $(GOPATH)/src/github.com/nanu-c/axolotl
AXOLOTL_GIT_VERSION := $(shell git tag | tail --lines=1)
AXOLOTL_VERSION := $(subst v,,$(AXOLOTL_GIT_VERSION))

check-platform-arm64:
	@echo "Building Axolotl for Debian arm64/aarch64"
  ifneq ($(shell uname),Linux)
	@echo "Platform unsupported - only available for Linux" && exit 1
  endif
  ifneq ($(shell uname -m),aarch64)
	@echo "Machine unsupported - only available for arm64/aarch64" && exit 1
  endif
  ifneq ($(shell which apt),/usr/bin/apt)
	@echo "OS unsupported - apt not found" && exit 1
  endif

dependencies-arm64:
	@echo "Installing dependencies for building Axolotl..."
	@sudo apt update
	@sudo apt install git golang nodejs npm python

build-arm64:
	@echo "Downloading (go)..."
	@cd $(WORKDIR) && go mod download
	@echo "Installing (npm)..."
	@cd $(WORKDIR)/axolotl-web && npm ci
	@echo "Building (npm)..."
	@cd $(WORKDIR)/axolotl-web && npm run build
	@mkdir -p $(WORKDIR)/build/linux-arm64/axolotl-web
	@echo "Building (go)..."
	@cd $(WORKDIR) && env GOOS=linux GOARCH=arm64 go build -o build/linux-arm64/axolotl .
	@cp -r axolotl-web/dist build/linux-arm64/axolotl-web
	@cp -r guis build/linux-arm64
	@echo "Building complete."

prebuild-package-arm64: package-clean-arm64
	@echo "Prebuilding Debian package..."
# Get the source tarball
	@wget https://github.com/nanu-c/axolotl/archive/v$(AXOLOTL_VERSION).tar.gz -O $(WORKDIR)/axolotl-$(AXOLOTL_VERSION).tar.gz
# Prepare packaging folder
	@mkdir -p $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/axolotl
	@cp -r $(WORKDIR)/build/linux-arm64/* $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/axolotl
	@cp $(WORKDIR)/deb/LICENSE $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/LICENSE
# Run debmake
	@cd $(WORKDIR)/axolotl-$(AXOLOTL_VERSION) && debmake -e arno_nuehm@riseup.net -f "Arno Nuehm" -m
# Create target folders and copy additional files into package folder
	@mkdir -p $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/usr/share/icons/hicolor/128x128/apps
	@mkdir -p $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/usr/share/applications
	@mkdir -p $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/usr/bin
	@mkdir -p $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/etc/profile.d
	@cp $(WORKDIR)/README.md $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/debian/README.Debian
	@cp $(WORKDIR)/deb/axolotl.png $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/usr/share/icons/hicolor/128x128/apps/axolotl.png
	@cp $(WORKDIR)/deb/axolotl.desktop $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/usr/share/applications
	@cp $(WORKDIR)/deb/axolotl.sh $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/etc/profile.d
	@cp $(WORKDIR)/deb/axolotl.install $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/debian
	@cp $(WORKDIR)/deb/postinst $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/debian
	@cp $(WORKDIR)/deb/control $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/debian/control
	@wget https://github.com/nanu-c/zkgroup/raw/main/lib/libzkgroup_linux_arm64.so -P  $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/usr/lib
	@mv $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/axolotl/axolotl $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/usr/bin
	@echo "Prebuilding Debian package complete"

build-package-arm64:
	@echo "Building Debian package..."
# Prompt to edit changelog file
	@nano $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/debian/changelog
# Prompt to edit copyright file
	@nano $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/debian/copyright
# Build Debian package
	@cd $(WORKDIR)/axolotl-$(AXOLOTL_VERSION) && debuild -i -us -uc -b

install-arm64: uninstall-arm64
# Use for testing purposes only after prebuild-package-arm64
	@echo "Installing Axololt"
# Copy libzkgroup
	@sudo wget https://github.com/nanu-c/zkgroup/raw/main/lib/libzkgroup_linux_arm64.so -P /usr/lib
	@sudo mkdir -p /usr/share/axolotl
	@sudo cp -r $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)/axolotl/* /usr/share/axolotl
	@sudo mv /usr/share/axolotl/axolotl /usr/bin/
	@sudo cp $(WORKDIR)/deb/axolotl.desktop /usr/share/applications
	@sudo cp $(WORKDIR)/deb/axolotl.png /usr/share/icons/hicolor/128x128/apps
	@sudo cp $(WORKDIR)/deb/axolotl.sh /etc/profile.d
	@bash -c "source /etc/profile.d/axolotl.sh"
	@echo "Installation complete"

uninstall-arm64:
	@sudo rm -rf /usr/share/axolotl
	@sudo rm -f /usr/bin/axolotl
	@sudo rm -f /usr/share/applications/axolotl.desktop
	@sudo rm -f /usr/share/icons/hicolor/128x128/apps/axolotl.png
	@sudo rm -f /etc/profile.d/axolotl.sh
	@sudo rm -f /usr/lib/libzkgroup_linux_arm64.so
	@echo "Removing complete"

clean-arm64:
	@rm -rf $(WORKDIR)/build

package-clean-arm64:
	@rm -rf $(WORKDIR)/axolotl-$(AXOLOTL_VERSION)
