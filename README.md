# axolotl-debian-packaging
These files are used to create a Debian package of [Axolotl](https://github.com/nanu-c/axolotl) for Mobian (Debian aarch64/arm64)

# Checking/Feedback
Please feel free to check the files for non-Debian-conform commands or behaviour. Any feedback is very welcome.

# Building steps
## Download source
```
go get -d -u github.com/nanu-c/axolotl/
```

## Copy necessary files
The files found here are not yet uploaded to the source, because they are experimental.
To check the behaviour, copy them into the source folder via
```
git clone https://github.com/nuehm-arno/axolotl-debian-packaging
cp -r $HOME/axolotl-debian-packaging/deb $(go env GOPATH)/src/github.com/nanu-c/axolotl
cp -r $HOME/axolotl-debian-packaging/Makefile $(go env GOPATH)/src/github.com/nanu-c/axolotl
```
and follow the next steps.


## Building the binary
```
cd $(go env GOPATH)/src/github.com/nanu-c/axolotl
make build
```

## Prebuilding the Debian package
```
cd $(go env GOPATH)/src/github.com/nanu-c/axolotl
make prebuild_package
```

## Building the Debian package
In this step, you will be asked to add metadata to the package files "changelog" and "copyright".
The info for "changelog" is the number of closed bugs "#nnnn", which I cannot provide (--> resulting in a lintian error message).
And the info for "copyright" is Upstream-Contact "nanu-c" and Source "https://github.com/nanu-c/axolotl".
```
cd $(go env GOPATH)/src/github.com/nanu-c/axolotl
make build_package
```

# Lintian log file
The log file was created using this setup.
Please let me know, if you have suggestions - any help is welcome!
