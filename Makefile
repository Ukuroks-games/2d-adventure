LIBNAME = 2d-adventure

PACKAGE_NAME = $(LIBNAME)lib.zip

CP = cp -rf
MV = mv -f
RM = rm -rf

BUILD_DIR = build

RBXM_BUILD = $(LIBNAME)lib.rbxm

SOURCES =	src/init.lua			\
			src/BaseCharacter.lua	\
			src/AnimatedObject.lua	\
			src/Character.lua		\
			src/player.lua			\
			src/Object2d.lua		\
			src/map.lua				\
			src/physicObject.lua	\
			src/gifInfo.lua			\
			src/ExImage.lua			\
			src/camera2d.lua		\
			src/ControlClass.lua	\
			src/ControlType.lua		\
			src/defaultControls.lua	\
			src/config.luau

$(BUILD_DIR): 
	mkdir $@

wally.lock: wally.toml
	wally install

./Packages: wally.lock
	


configure: clean-build $(BUILD_DIR) wally.toml $(SOURCES)
	$(CP) src/* $(BUILD_DIR)
	$(CP) wally.toml build/

package: configure $(SOURCES)
	wally package --output $(PACKAGE_NAME) --project-path $(BUILD_DIR)

publish: configure $(SOURCES)
	wally publish --project-path $(BUILD_DIR)

lint:
	selene src/ tests/

$(RBXM_BUILD): library.project.json	$(SOURCES)
	rojo build library.project.json --output $@


demo.rbxl: ./Packages demo.project.json $(SOURCES) tests/demo/test.client.luau
	rojo build demo.project.json --output $@

TestMovableObjects.rbxl: ./Packages TestMovableObjects.project.json $(SOURCES) tests/TestMovableObjects/test.client.luau
	rojo build TestMovableObjects.project.json --output $@

ALL_TESTS =	demo.rbxl	\
			TestMovableObjects.rbxl

tests: clean-tests $(ALL_TESTS)

sourcemap.json: ./Packages defaultTests.project.json
	rojo sourcemap defaultTests.project.json --output $@

# Re gen sourcemap
sourcemap: clean-sourcemap sourcemap.json


clean-sourcemap: 
	$(RM) sourcemap.json

clean-rbxm:
	$(RM) $(RBXM_BUILD)

clean-tests:
	$(RM) $(ALL_TESTS)

clean-build:
	$(RM) $(BUILD_DIR)

clean: clean-tests clean-build clean-rbxm
	$(RM) $(PACKAGE_NAME) 
