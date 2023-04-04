MAKEFLAGS += -Orecurse

SPACK ?= spack
SPACK_INSTALL_FLAGS += --no-check-signature

export SPACK_COLOR = always

SPACK_ENV ?= dev

BUILDCACHE := $(SPACK_ENV)/cache

.PHONY: all clean

all: $(SPACK_ENV)/push

ifeq (,$(filter clean,$(MAKECMDGOALS)))
include $(SPACK_ENV)/spack.mk
endif

$(SPACK_ENV)/push: $(addprefix $(SPACK_ENV)/push/,$($(SPACK_ENV)/SPACK_PACKAGE_IDS))
	@mkdir -p $(BUILDCACHE)
	$(foreach buildcache, $(BUILDCACHE), $(SPACK) buildcache update-index $(buildcache) ;)

$(SPACK_ENV)/push/%: $(SPACK_ENV)/install/%
	@mkdir -p $(dir $@)
	$(foreach buildcache, $(BUILDCACHE), $(SPACK) buildcache create --allow-root --only=package --unsigned $(buildcache) /$(HASH) ;) # push $(SPEC)
	@touch $@

$(SPACK_ENV)/spack.lock: $(SPACK_ENV)/spack.yaml Makefile
	$(SPACK) concretize --force --fresh

$(SPACK_ENV)/spack.mk: $(SPACK_ENV)/spack.lock Makefile
	$(SPACK) env depfile --output $@ --make-target-prefix $(SPACK_ENV)

clean:
	rm -rf $(SPACK_ENV)/spack.lock $(SPACK_ENV)/spack.mk
