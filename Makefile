IS := $(subst /,,$(dir $(wildcard */*.sh)))

.PHONY: all ${IS}
all: ${IS}

${IS}:
	$@/$@.sh build
