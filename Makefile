LIBNAME = 2d-adventure

PACKAGE_NAME = $(LIBNAME)lib.zip

CP = cp -rf
MV = mv -f
RM = rm -rf

BUILD_DIR = build

RBXM_BUILD = $(LIBNAME)lib.rbxm

GENERATE_SOURCEMAP = defaultTests

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
			src/game.lua			\
			src/config.luau

$(BUILD_DIR):
	mkdir $@

wallyInstall:	wally.toml
	wally install
	rojo sourcemap defaultTests.project.json --output sourcemap.json

wally.lock:	wallyInstall

./Packages:	wallyInstall
	wally-package-types --sourcemap sourcemap.json $@

./DevPackages:	wallyInstall
	wally-package-types --sourcemap sourcemap.json $@


BUILD_SOURCES = $(addprefix $(BUILD_DIR)/, $(notdir $(SOURCES)))

$(BUILD_DIR)/wally.toml:	$(BUILD_DIR)	wally.toml
	$(CP) wally.toml build/

MV_SOURCES:	$(BUILD_DIR)	$(SOURCES)
	$(CP) src/* $(BUILD_DIR)

$(BUILD_SOURCES):	MV_SOURCES


$(PACKAGE_NAME):	$(BUILD_SOURCES)	$(BUILD_DIR)/wally.toml
	wally package --output $(PACKAGE_NAME) --project-path $(BUILD_DIR)


package:	clean-package	clean-build	$(PACKAGE_NAME)
	

publish:	clean-build	$(BUILD_SOURCES)	$(BUILD_DIR)/wally.toml	
	wally publish --project-path $(BUILD_DIR)


lint:
	selene src/ tests/


$(RBXM_BUILD): ./Packages	library.project.json	$(SOURCES)
	rojo build library.project.json --output $@


demo.rbxl:	./Packages	./DevPackages	demo.project.json	$(SOURCES)	tests/demo/test.client.luau
	rojo build demo.project.json --output $@

TestMovableObjects.rbxl:	./Packages	TestMovableObjects.project.json	$(SOURCES)	tests/TestMovableObjects/test.client.luau
	rojo build TestMovableObjects.project.json --output $@

ALL_TESTS =	demo.rbxl	\
			TestMovableObjects.rbxl

tests: clean-tests $(ALL_TESTS)


sourcemap.json:	./Packages	./DevPackages	$(GENERATE_SOURCEMAP).project.json $(SOURCES)
	rojo sourcemap $(GENERATE_SOURCEMAP).project.json --output $@

# Re gen sourcemap
sourcemap:	sourcemap.json


clean-sourcemap: 
	$(RM) sourcemap.json

clean-rbxm:
	$(RM) $(RBXM_BUILD)

clean-tests:
	$(RM) $(ALL_TESTS)

clean-build:
	$(RM) $(BUILD_DIR)/*

clean-package:
	$(RM) $(PACKAGE_NAME) 

clean:	clean-tests	clean-build	clean-rbxm	clean-package
