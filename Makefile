LIBNAME = 2d-adventure

PACKAGE_NAME = $(LIBNAME)lib.zip

CP = cp -rf
MV = mv -f
RM = rm -rf

BUILD_DIR = build
LIB_BUILD_DIR = $(BUILD_DIR)

$(BUILD_DIR): 
	mkdir $@

$(LIB_BUILD_DIR):
	mkdir $@

./Packages: wally.toml
	wally install
	


configure: clean-build $(BUILD_DIR)
	$(CP) src/* $(BUILD_DIR)
	$(CP) wally.toml build/

package: configure
	wally package --output $(PACKAGE_NAME) --project-path build

publish: configure
	wally publish --project-path build

lint:
	selene src/ tests/


rbxm-configure-copy: ./Packages $(LIB_BUILD_DIR)
	$(CP) Packages $(BUILD_DIR)
	$(CP) src/* $(LIB_BUILD_DIR)

rbxm-configure: $(BUILD_DIR)
	make "LIB_BUILD_DIR = $(BUILD_DIR)/$(LIBNAME)" rbxm-configure-copy

$(LIBNAME)lib.rbxm: clean-build rbxm-configure
	rojo build library.project.json --output $@

tests.rbxl: ./Packages
	rojo build tests.project.json --output $@

tests: clean-tests clean-build tests.rbxl

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

clean-build:
	$(RM) $(BUILD_DIR)

clean: clean-tests clean-build clean-rbxm
	$(RM) $(PACKAGE_NAME) 
