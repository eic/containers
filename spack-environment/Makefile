MAKEFLAGS += -Orecurse

SPACK ?= spack
SPACK_INSTALL_FLAGS += --no-check-signature

export SPACK_COLOR = always

SPACK_ENV ?= dev

BUILDCACHE_MIRROR_ONLY_PACKAGE :=
BUILDCACHE_MIRROR_DEPENDENCIES :=
BUILDCACHE_OCI_BASE_IMAGE := amd64/debian:stable-slim

.PHONY: all clean

all: $(SPACK_ENV)/push

ifeq (,$(filter clean,$(MAKECMDGOALS)))
include $(SPACK_ENV)/spack.mk
endif

$(SPACK_ENV)/push: $(addprefix $(SPACK_ENV)/push/,$($(SPACK_ENV)/SPACK_PACKAGE_IDS))
	$(foreach buildcache, $(BUILDCACHE_MIRROR_ONLY_PACKAGE), $(SPACK) buildcache update-index $(buildcache) ;)
	$(foreach buildcache, $(BUILDCACHE_MIRROR_DEPENDENCIES), $(SPACK) buildcache update-index $(buildcache) ;)

$(SPACK_ENV)/push/%: $(SPACK_ENV)/install/%
	@mkdir -p $(dir $@)
	$(foreach buildcache, $(BUILDCACHE_MIRROR_ONLY_PACKAGE), $(SPACK) buildcache push --only=package --unsigned $(buildcache) /$(HASH) ;) # push $(SPEC)
	$(foreach buildcache, $(BUILDCACHE_MIRROR_DEPENDENCIES), $(SPACK) buildcache push --unsigned --base-image $(BUILDCACHE_OCI_BASE_IMAGE) $(buildcache) /$(HASH) ;) # push $(SPEC)
	@touch $@

$(SPACK_ENV)/spack.lock: $(SPACK_ENV)/spack.yaml Makefile
	$(SPACK) concretize --force --fresh

$(SPACK_ENV)/spack.mk: $(SPACK_ENV)/spack.lock Makefile
	$(SPACK) env depfile --output $@ --make-target-prefix $(SPACK_ENV)

clean:
	rm -rf $(SPACK_ENV)/spack.lock $(SPACK_ENV)/spack.mk
