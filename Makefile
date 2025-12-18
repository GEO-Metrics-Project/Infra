.PHONY: infra-namespace metallb all

SCRIPT_DIR=$(shell cd scripts/setup && pwd)
SETUP_SCRIPT=$(SCRIPT_DIR)/setup-infra.sh

infra-namespace:
	bash $(SETUP_SCRIPT) create_namespace

metallb:
	bash $(SETUP_SCRIPT) setup_metallb

all: infra-namespace helm-repos