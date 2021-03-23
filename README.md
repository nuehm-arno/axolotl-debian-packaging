# axolotl-debian-packaging
These files are used to create an experimental Debian package of [Axolotl](https://github.com/nanu-c/axolotl) for Mobian (Debian aarch64/arm64).

# Checking/Feedback
Please feel free to check the files for non-Debian-conform commands or behaviour. Any feedback is very welcome.

# Building steps
## Download source
You need to have "go" installed to get the source compatible for the next steps.
```
sudo apt install golang
go get -d -u github.com/nanu-c/axolotl/
```

## Copy necessary files
The files found here are not yet uploaded to the source, because they are experimental.

To check the behaviour, copy them into the source folder via
```
git clone https://github.com/nuehm-arno/axolotl-debian-packaging.git
cp -r $HOME/axolotl-debian-packaging/deb $(go env GOPATH)/src/github.com/nanu-c/axolotl
cp -r $HOME/axolotl-debian-packaging/Makefile $(go env GOPATH)/src/github.com/nanu-c/axolotl
```
and follow the next steps.


## Building the binary
```
cd $(go env GOPATH)/src/github.com/nanu-c/axolotl
make
```

## Prebuilding the Debian package
```
cd $(go env GOPATH)/src/github.com/nanu-c/axolotl
make prebuild_package_arm64
```

## Building the Debian package
During this step, you will be asked to add metadata to the package files "changelog" and "copyright".

In "changelog" the bug number of "intend-to-package" (ITP) has to be added, when available.

In "copyright" the Upstream-Contact is "nanu-c" and the Source is "https://github.com/nanu-c/axolotl".
```
cd $(go env GOPATH)/src/github.com/nanu-c/axolotl
make build_package_arm64
```

# Lintian log file
The log file was created using this setup.
Please let me know, if you have suggestions - any help is welcome.
