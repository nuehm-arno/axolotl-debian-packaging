# axolotl-debian-packaging
These files are used to create an unofficial Debian package of [Axolotl](https://github.com/nanu-c/axolotl) for Mobian (Debian arm64/aarch64).

# Checking/Feedback
Please feel free to check the files for non-Debian-conform commands or behaviour. Any feedback is very welcome.

# Building steps
## Download source
You need to have "go" and "git" installed to get the source compatible for the next steps.
```
sudo apt install golang git
go get -d -u github.com/nanu-c/axolotl/
```

Use these commands to build a specific branch of Axolotl (v0.9.9 for example).
```
sudo apt install golang git
export GO111MODULE=on
go get -d github.com/nanu-c/axolotl@v0.9.9
```

## Copy necessary files
The files found here are not yet uploaded to the source, because they are experimental.

To check the behaviour, copy them into the source folder via
```
git clone https://github.com/nuehm-arno/axolotl-debian-packaging
cp -r $HOME/axolotl-debian-packaging/deb $(go env GOPATH)/src/github.com/nanu-c/axolotl
cat $HOME/axolotl-debian-packaging/Makefile >> $(go env GOPATH)/src/github.com/nanu-c/axolotl/Makefile
```
and follow the next steps.

And for building a specific branch (v0.9.9), use these commands
```
git clone https://github.com/nuehm-arno/axolotl-debian-packaging
cp -r $HOME/axolotl-debian-packaging/deb $(go env GOPATH)/pkg/mod/github.com/nanu-c/axolotl@v0.9.9
cat $HOME/axolotl-debian-packaging/Makefile_v0.9.9-3 >> $(go env GOPATH)/pkg/mod/github.com/nanu-c/axolotl@v0.9.9/Makefile
```

## Building the binary
Execute this in the Axolotl folder
```
make build-arm64
```

## Prebuilding the Debian package
Execute this in the Axolotl folder
```
make prebuild-package-arm64
```

## Building the Debian package
During this step, you will be asked to add metadata to the package files "changelog" and "copyright".

In "changelog" the bug number of "intend-to-package" (ITP) has to be added, when available.

In "copyright" the Upstream-Contact is "aaron@nanu-c.org" and the Source is "https://github.com/nanu-c/axolotl".

Execute this in the Axolotl folder
```
make build-package-arm64
```

## Lintian log
You can find the Lintian log [here](lintian_log).
