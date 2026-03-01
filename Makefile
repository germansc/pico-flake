# PICO 2 W PROJECT MAKEFILE
# Wrapper around CMake for the Raspberry Pi Pico SDK build system.
#
# 2026 - germansc
#
# -------------------------------------------------------------- PROJECT SETUP
PROJECT_NAME = PICO 2 W TEMPLATE
AUTHOR = GERMANSC

BUILD_PATH = build
BIN_NAME = pico-sdk

SRC_PATH = src
TEST_SRC_PATH = test/tests

# DEFAULT TARGET #
.PHONY: default_target
default_target: help

# ---------------------------------------------------------- AUXILIARY TARGETS
.PHONY: help
help:
	@echo
	@echo "$(PROJECT_NAME)"
	@echo "----------------------------------------------"
	@echo "$(AUTHOR)"
	@echo ""
	@echo "BUILD TARGETS:"
	@echo "    build      : Configure and build the firmware (.uf2)"
	@echo "    rebuild    : Clean and build from scratch"
	@echo ""
	@echo "FLASH TARGETS:"
	@echo "    flash      : Reboot pico into BOOTSEL and flash"
	@echo ""
	@echo "DEVELOPMENT TARGETS:"
	@echo "    module <p> : Generate a new source module at the given path"
	@echo "    test       : Run all unit tests"
	@echo ""
	@echo "AUXILIARY TARGETS:"
	@echo "    clean      : Remove all build artifacts"
	@echo "    help       : This help message"
	@echo ""

.PHONY: clean
clean:
	@echo "Deleting build directory..."
	@$(RM) -r $(BUILD_PATH)
	@echo "Done."

# -------------------------------------------------------------- BUILD TARGETS
.PHONY: build
build: $(BUILD_PATH)/$(BIN_NAME).uf2

$(BUILD_PATH)/$(BIN_NAME).uf2: $(BUILD_PATH)/Makefile $(shell find src -name '*.[ch]' 2>/dev/null)
	@echo ""
	@echo "Building firmware..."
	$(MAKE) -C $(BUILD_PATH) -j$(shell nproc)
	@echo ""
	@echo "Build complete!"
	@echo "Firmware: $(BUILD_PATH)/$(BIN_NAME).uf2"
	@echo ""

$(BUILD_PATH)/Makefile: CMakeLists.txt pico_sdk_import.cmake
	@echo ""
	@echo "Configuring CMake build..."
	@mkdir -p $(BUILD_PATH)
	cmake -B $(BUILD_PATH) -S . -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
	@ln -sf $(BUILD_PATH)/compile_commands.json compile_commands.json
	@echo ""

.PHONY: rebuild
rebuild: clean build

# -------------------------------------------------------------- FLASH TARGETS

.PHONY: flash
flash: build
	@echo ""
	@echo "Rebooting pico into BOOTSEL mode and flashing..."
	picotool reboot -f -u
	@sleep 2
	picotool load -v -x $(BUILD_PATH)/$(BIN_NAME).uf2
	@echo ""

# -------------------------------------------------------- DEVELOPMENT TARGETS

# -- Module Generator Target --
# Parse additional arguments as parameters instead of additional targets.
ifeq (module,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "run"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)

  MODULE_ARG=$(firstword $(RUN_ARGS))
  MODULE=$(MODULE_ARG:src/%=%)
  FILENAME=$(shell basename $(MODULE))
  DIRNAME=$(shell dirname $(MODULE))
  FILENAME_UPPER=$(shell echo $(FILENAME) | tr a-z A-Z)
  DIRNAME_UPPER=$(shell echo $(DIRNAME) | tr a-z A-Z | tr / _)
  DATE_STR=$(shell date '+%B %Y')
endif

module:
	@echo "Creating new $(FILENAME) module at: src/$(DIRNAME)"
	@mkdir -p $(SRC_PATH)/$(DIRNAME)
	@mkdir -p $(TEST_SRC_PATH)/$(DIRNAME)
	@cp templates/module.c $(SRC_PATH)/$(DIRNAME)/$(FILENAME).c
	@cp templates/module.h $(SRC_PATH)/$(DIRNAME)/$(FILENAME).h
	@cp templates/test_module.c $(TEST_SRC_PATH)/$(DIRNAME)/test_$(FILENAME).c
	@sed -i "s|PROJECT_TAG|$(PROJECT_NAME)|g" $(SRC_PATH)/$(DIRNAME)/$(FILENAME).[ch] $(TEST_SRC_PATH)/$(DIRNAME)/test_$(FILENAME).c
	@sed -i "s|DIR_TAG|$(DIRNAME)|g" $(SRC_PATH)/$(DIRNAME)/$(FILENAME).[ch] $(TEST_SRC_PATH)/$(DIRNAME)/test_$(FILENAME).c
	@sed -i "s|FILE_TAG|$(FILENAME)|g" $(SRC_PATH)/$(DIRNAME)/$(FILENAME).[ch] $(TEST_SRC_PATH)/$(DIRNAME)/test_$(FILENAME).c
	@sed -i "s|DIR_UPPER_TAG|$(DIRNAME_UPPER)|g" $(SRC_PATH)/$(DIRNAME)/$(FILENAME).[ch] $(TEST_SRC_PATH)/$(DIRNAME)/test_$(FILENAME).c
	@sed -i "s|FILE_UPPER_TAG|$(FILENAME_UPPER)|g" $(SRC_PATH)/$(DIRNAME)/$(FILENAME).[ch] $(TEST_SRC_PATH)/$(DIRNAME)/test_$(FILENAME).c
	@sed -i "s|AUTHOR_TAG|$(USER)|g" $(SRC_PATH)/$(DIRNAME)/$(FILENAME).[ch] $(TEST_SRC_PATH)/$(DIRNAME)/test_$(FILENAME).c
	@sed -i "s|DATE_TAG|$(DATE_STR)|g" $(SRC_PATH)/$(DIRNAME)/$(FILENAME).[ch] $(TEST_SRC_PATH)/$(DIRNAME)/test_$(FILENAME).c

# --------------------------------------------------------------- TEST TARGETS
#  The tests targets should redirect to the ceedling tool using the 'test'
#  directory as working dir.

# -- Test Target Redirect --
ifeq (test,$(firstword $(MAKECMDGOALS)))
# Parse additional arguments as parameters instead of additional targets.
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)

  TEST_ARG=$(strip $(firstword $(RUN_ARGS)))
  ifeq ($(TEST_ARG),)
	TEST_ARG="all"
  endif

endif

.PHONY: test
test: ## Redirige el siguiente target al makefile de `test`.
	@echo "Testing $(TEST_ARG)"
	$(MAKE) -C test $(TEST_ARG)
