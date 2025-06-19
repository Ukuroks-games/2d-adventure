LIBNAME = 2d-adventure

PACKAGE_NAME = $(LIBNAME).zip

CP = cp -rf
MV = mv -f
RM = rm -rf

./build: 
	mkdir build
	
configure: ./build wally.toml src/*
	$(CP) src/* build/
	$(MV) build/$(LIBNAME).lua build/init.lua
	$(CP) wally.toml build/

package: configure
	wally package --output $(PACKAGE_NAME) --project-path build

publish: configure
	wally publish --project-path build

lint:
	selene src/ tests/

./Packages: wally.toml
	wally install

$(LIBNAME).rbxm: configure
	rojo build library.project.json --output $@

tests: ./Packages
	rojo build tests.project.json --output tests.rbxl

tests.rbxl: tests

sourcemap.json: ./Packages
	rojo sourcemap tests.project.json --output $@

delete-sourcemap: 
	$(RM) sourcemap.json

# Re gen sourcemap
sourcemap: delete-sourcemap sourcemap.json

clean:
	$(RM) build $(PACKAGE_NAME) $(LIBNAME).rbxm
