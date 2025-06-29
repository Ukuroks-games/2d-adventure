LIBNAME = 2d-adventure

PACKAGE_NAME = $(LIBNAME).zip

CP = cp -rf
MV = mv -f
RM = rm -rf

./build: 
	mkdir build

./Packages: wally.toml
	wally install
	
configure: clean ./build wally.toml src/%.lua
	$(CP) src/* build/
	$(CP) wally.toml build/

package: configure
	wally package --output $(PACKAGE_NAME) --project-path build

publish: configure
	wally publish --project-path build

lint:
	selene src/ tests/



$(LIBNAME).rbxm: configure
	$(MV) build/init.lua build/$(LIBNAME).lua
	rojo build library.project.json --output $@

tests.rbxl: ./Packages
	rojo build tests.project.json --output tests.rbxl

tests: clean-tests tests.rbxl

sourcemap.json: ./Packages
	rojo sourcemap tests.project.json --output $@

# Re gen sourcemap
sourcemap: clean-sourcemap sourcemap.json


clean-sourcemap: 
	$(RM) sourcemap.json

clean-rbxm:
	$(RM) $(LIBNAME).rbxm 

clean-tests:
	$(RM) tests.rbxl

clean: clean-tests clean-rbxm
	$(RM) build $(PACKAGE_NAME) 
