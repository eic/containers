MAKEFLAGS += -Oline

SPACK ?= spack --backtrace --yes-to-all
SPACK_INSTALL_FLAGS += --no-check-signature --show-log-on-error

export SPACK_COLOR = always

SPACK_ENV ?= dev

BUILDCACHE_OCI_FINAL :=
BUILDCACHE_OCI_BASE_IMAGE := ghcr.io/eic/debian:stable-slim

.PHONY: all clean

all: $(SPACK_ENV)/push

ifeq (,$(filter clean,$(MAKECMDGOALS)))
include $(SPACK_ENV)/spack.mk
endif

$(SPACK_ENV)/push: $(addprefix $(SPACK_ENV)/push/,$($(SPACK_ENV)/SPACK_PACKAGE_IDS))
	$(foreach buildcache, $(BUILDCACHE_OCI_FINAL), $(SPACK) buildcache push --private --unsigned --base-image $(BUILDCACHE_OCI_BASE_IMAGE) $(buildcache) | grep -v "Using cached archive" ;)

$(SPACK_ENV)/push/%: $(SPACK_ENV)/install/%
	@mkdir -p $(dir $@)
	@touch $@

$(SPACK_ENV)/spack.lock: $(SPACK_ENV)/spack.yaml Makefile
	$(SPACK) concretize --force --fresh

$(SPACK_ENV)/spack.mk: $(SPACK_ENV)/spack.lock Makefile
	$(SPACK) env depfile --output $@ --make-target-prefix $(SPACK_ENV)

clean:
	rm -rf $(SPACK_ENV)/spack.lock $(SPACK_ENV)/spack.mk
