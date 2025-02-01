INC_DIR := ./include
RESULTS_DIR := ./results

# Define Top Module Here
TOP_MODULE 	:= user_project_wrapper
TOP_FILE	:= $(shell find . -name '$(TOP_MODULE).sv' -or -name '$(TOP_MODULE).v')
RTL_SRCS 	:= $(shell find . -name '*.sv' -or -name '*.v')

# Define anything you don't want synthesized here, % is wildcard
DONT_SYNTH := ./core/rtl/wrapper_modules/% ./tests/%
SNYTH_SRCS := $(filter-out $(DONT_SYNTH), $(RTL_SRCS))

INCLUDE_DIRS := $(sort $(dir $(shell find . -name '*.svh')))
RTL_DIRS	 := $(sort $(dir $(RTL_SRCS)))
# Include both Include and RTL directories for linting
LINT_INCLUDES := $(foreach dir, $(INCLUDE_DIRS) $(RTL_DIRS), -I$(realpath $(dir)))

TEST_DIR = ./tests
TESTS = $(shell cd $(TEST_DIR) && ls -d */ | grep -v "__pycache__" )

LINTER := verilator
LINT_OPTS += --lint-only --timing $(LINT_INCLUDES)

# Text formatting for tests
BOLD = `tput bold`
GREEN = `tput setaf 2`
ORANG = `tput setaf 214`
RED = `tput setaf 1`
RESET = `tput sgr0`

TEST_GREEN := $(shell tput setaf 2)
TEST_ORANGE := $(shell tput setaf 214)
TEST_RED := $(shell tput setaf 1)
TEST_RESET := $(shell tput sgr0)

all: lint_all synth_check tests

lint: lint_all

.PHONY: lint_all
lint_all: 
	@printf "\n$(GREEN)$(BOLD) ----- Linting All Modules ----- $(RESET)\n"
	@for src in $(RTL_SRCS); do \
		top_module=$$(basename $$src .sv); \
		top_module=$$(basename $$top_module .v); \
		printf "Linting $$src . . . "; \
		if $(LINTER) $(LINT_OPTS) --top-module $$top_module $$src > /dev/null 2>&1; then \
			printf "$(GREEN)PASSED$(RESET)\n"; \
		else \
			printf "$(RED)FAILED$(RESET)\n"; \
			$(LINTER) $(LINT_OPTS) --top-module $$top_module $$src; \
		fi; \
	done

.PHONY: lint_top
lint_top:
	@printf "\n$(GREEN)$(BOLD) ----- Linting $(TOP_MODULE) ----- $(RESET)\n"
	@printf "Linting Top Level Module: $(TOP_FILE)\n";
	$(LINTER) $(LINT_OPTS) --top-module $(TOP_MODULE) $(TOP_FILE)

tests: $(TESTS) 

.PHONY: $(TESTS)
$(TESTS): 
# Run Makefile in each test directory
	# @printf $(call test_text,$@)
	$(MAKE) -C $(TEST_DIR)/$@

# Copy results.xml and coverage.dat to results folder
	@mkdir -p $(RESULTS_DIR)/$@
	@cp $(TEST_DIR)/$@/results.xml $(RESULTS_DIR)/$@
    @cp $(TEST_DIR)/$@/coverage.dat $(RESULTS_DIR)/$@ || :

# If waveform dumping is enabled, copy dump.vcd to results folder
ifdef WAVES
	@echo Copying Waves...
	@cp $(TEST_DIR)/$@/dump.vcd $(RESULTS_DIR)/$@
endif
	
.PHONY: clean
clean:
# Remove results directory and clean core
	-rm -rf $(RESULTS_DIR)
	$(foreach test,$(TESTS), make -C $(TEST_DIR)/$(test) clean $(var);)
