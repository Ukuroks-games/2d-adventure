LIBNAME = 2d-adventure

PACKAGE_NAME = $(LIBNAME)lib.zip

CP = cp -rf
MV = mv -f
RM = rm -rf

BUILD_DIR = build

RBXM_BUILD = $(LIBNAME)lib.rbxm

$(BUILD_DIR): 
	mkdir $@

./Packages: wally.toml
	wally install
	


configure: clean-build $(BUILD_DIR) wally.toml
	$(CP) src/* $(BUILD_DIR)
	$(CP) wally.toml build/

package: configure
	wally package --output $(PACKAGE_NAME) --project-path $(BUILD_DIR)

publish: configure
	wally publish --project-path $(BUILD_DIR)

lint:
	selene src/ tests/

$(RBXM_BUILD): library.project.json
	rojo build library.project.json --output $@

tests.rbxl: ./Packages tests.project.json
	rojo build tests.project.json --output $@

tests: clean-tests clean-build tests.rbxl

sourcemap.json: ./Packages tests.project.json
	rojo sourcemap tests.project.json --output $@

# Re gen sourcemap
sourcemap: clean-sourcemap sourcemap.json


clean-sourcemap: 
	$(RM) sourcemap.json

clean-rbxm:
	$(RM) $(RBXM_BUILD)

clean-tests:
	$(RM) tests.rbxl

clean-build:
	$(RM) $(BUILD_DIR)

clean: clean-tests clean-build clean-rbxm
	$(RM) $(PACKAGE_NAME) 
