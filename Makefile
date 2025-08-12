LIBNAME = 2d-adventure

PACKAGE_NAME = $(LIBNAME)lib.zip

CP = cp -rf
MV = mv -f
RM = rm -rf

BUILD_DIR = build

RBXM_BUILD = $(LIBNAME)lib.rbxm

ROJO_PROJECTS = rojo-projects

GENERATE_SOURCEMAP = defaultTests
FULL_GENERATE_SOURCEMAP = $(ROJO_PROJECTS)/$(GENERATE_SOURCEMAP).project.json

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
			src/config.luau			\
			src/Calc.luau

$(BUILD_DIR):
	mkdir $@

wallyInstall:	wally.toml
	wally install

wally.lock:	wallyInstall

./Packages:	wallyInstall

./DevPackages:	wallyInstall

PackagesTypes:	./Packages	sourcemap.json
	wally-package-types --sourcemap sourcemap.json Packages
	
DevPackagesTypes:	./DevPackages	sourcemap.json
	wally-package-types --sourcemap sourcemap.json DevPackages


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


$(RBXM_BUILD): ./Packages	$(ROJO_PROJECTS)/library.project.json	$(SOURCES)
	rojo build $(ROJO_PROJECTS)/library.project.json --output $@

demo.rbxl:	./Packages	./DevPackages	$(ROJO_PROJECTS)/demo.project.json	$(SOURCES)	tests/demo/test.client.luau
	rojo build $(ROJO_PROJECTS)/demo.project.json --output $@

TestMovableObjects.rbxl:	./Packages	$(ROJO_PROJECTS)/TestMovableObjects.project.json	$(SOURCES)	tests/TestMovableObjects/test.client.luau
	rojo build $(ROJO_PROJECTS)/TestMovableObjects.project.json --output $@

testCalc.rbxl:	./Packages	$(ROJO_PROJECTS)/testCalc.project.json	$(SOURCES)	tests/testCalc/tests.client.luau
	rojo build $(ROJO_PROJECTS)/testCalc.project.json --output $@

ALL_TESTS =	demo.rbxl	\
			TestMovableObjects.rbxl	\
			testCalc.rbxl

tests: clean-tests $(ALL_TESTS)


$(GENERATE_SOURCEMAP).project.json:	$(FULL_GENERATE_SOURCEMAP)
	$(CP) $< $@
	
sourcemap.json:	$(GENERATE_SOURCEMAP).project.json
	rojo sourcemap $< -o $@

# for manual run
sourcemap:	sourcemap.json	PackagesTypes	DevPackagesTypes 


clean-sourcemap:
	$(RM) *.json

clean-rbxm:
	$(RM) $(RBXM_BUILD)

clean-tests:
	$(RM) $(ALL_TESTS)

clean-build:
	$(RM) $(BUILD_DIR)/*

clean-package:
	$(RM) $(PACKAGE_NAME) 

clean:	clean-tests	clean-build	clean-rbxm	clean-package	clean-sourcemap
