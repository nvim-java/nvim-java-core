PREPARE_CONFIG=tests/prepare_config.lua
TEST_CONFIG=tests/test_config.lua
TESTS_DIR=tests/

.PHONY: test

test:
	@nvim \
		--headless \
		-u ${PREPARE_CONFIG} \
		"+PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${TEST_CONFIG}' }"
