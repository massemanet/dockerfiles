IS := $(subst /,,$(dir $(wildcard */*.sh)))

.PHONY: all ${IS}
all: ${IS}

${IS}:
	$@/$@.sh build

CIS := $(patsubst %, clean-%, ${IS})

.PHONY: clean ${CIS}
clean: ${CIS}

${CIS}: clean-%:
	$*/$*.sh delete
