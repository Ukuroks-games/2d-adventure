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

wally.lock	./Packages	./DevPackages:	wally.toml
	wally install

PackagesTypes:	./Packages	pre-sourcemap
	-wally-package-types --sourcemap sourcemap.json Packages
	
DevPackagesTypes:	./DevPackages	pre-sourcemap
	-wally-package-types --sourcemap sourcemap.json DevPackages

BUILD_SOURCES = $(addprefix $(BUILD_DIR)/, $(notdir $(SOURCES)))

$(BUILD_DIR)/wally.toml:	$(BUILD_DIR)	wally.toml
	$(CP) wally.toml build/

MV_SOURCES:	$(BUILD_DIR)	$(SOURCES)
	$(CP) src/* $(BUILD_DIR)

$(BUILD_SOURCES):	MV_SOURCES


$(PACKAGE_NAME):	$(BUILD_SOURCES)	$(BUILD_DIR)/wally.toml
	wally package --output $(PACKAGE_NAME) --project-path $(BUILD_DIR)

# Zip package
package:	clean-package	clean-build	$(PACKAGE_NAME)
	
# Publish
publish:	clean-build	$(BUILD_SOURCES)	$(BUILD_DIR)/wally.toml	
	wally publish --project-path $(BUILD_DIR)


lint:
	selene src/ tests/


$(RBXM_BUILD): library.project.json
	rojo build library.project.json --output $@

library.project.json:	$(SOURCES)	./Packages
	make "GENERATE_SOURCEMAP=library" $@

## RBXL

%.rbxl:	%.project.json
	rojo build $*.project.json --output $@

ALL_TESTS =	demo.rbxl	\
			TestMovableObjects.rbxl	\
			testCalc.rbxl

### rebuild add tests
tests: clean-tests $(ALL_TESTS)

### projects define

demo.project.json:	$(ROJO_PROJECTS)/demo.project.json	$(SOURCES)	tests/demo/test.client.luau	./Packages	./DevPackages
	make "GENERATE_SOURCEMAP=demo" $@

TestMovableObjects.project.json:	$(ROJO_PROJECTS)/TestMovableObjects.project.json	$(SOURCES)	tests/TestMovableObjects/test.client.luau	./Packages
	make "GENERATE_SOURCEMAP=TestMovableObjects" $@

testCalc.project.json:	$(ROJO_PROJECTS)/testCalc.project.json	$(SOURCES)	tests/testCalc/tests.client.luau	./Packages
	make "GENERATE_SOURCEMAP=testCalc" $@

defaultTests.project.json:	./Packages	./DevPackages

$(GENERATE_SOURCEMAP).project.json:	$(FULL_GENERATE_SOURCEMAP)
	$(CP) $< $@


pre-sourcemap:
	$(CP) $(ROJO_PROJECTS)/defaultTests.project.json defaultTests.project.json
	rojo sourcemap defaultTests.project.json -o sourcemap.json

sourcemap.json:	$(GENERATE_SOURCEMAP).project.json PackagesTypes DevPackagesTypes
	rojo sourcemap $< -o $@

# for manual run
sourcemap:	clean-sourcemap	sourcemap.json


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


.PHONY:	clean	\
		clean-sourcemap	\
		clean-rbxm	\
		clean-build	\
		clean-package	\
		pre-sourcemap	\
		PackagesTypes	\
		DevPackagesTypes	\
		package	\
		publish	\
		tests	\
		lint	\
		MV_SOURCES	\
		
	
.NOTPARALLEL: ./Packages ./DevPackages
