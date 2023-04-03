SPACK ?= spack
SPACK_INSTALL_FLAGS += --no-check-signature

BUILDCACHE := $(SPACK_ENV)/cache

.PHONY: all clean

all: push

ifeq (,$(filter clean,$(MAKECMDGOALS)))
include ${SPACK_ENV}/spack.mk
endif

${SPACK_ENV}/push: $(addprefix ${SPACK_ENV}/push/,$(SPACK_PACKAGE_IDS))
        $(SPACK) buildcache update-index --directory $(BUILDCACHE)

${SPACK_ENV}/push/%: ${SPACK_ENV}/install/%
        @mkdir -p $(dir $@)
        $(foreach buildcache, $(BUILDCACHE), $(SPACK) buildcache create --allow-root --only=package --unsigned $(buildcache) /$(HASH);)
        @touch $@

${SPACK_ENV}/spack.lock: ${SPACK_ENV}/spack.yaml
        $(SPACK) concretize --force

${SPACK_ENV}/spack.mk: ${SPACK_ENV}/spack.lock
        $(SPACK) env depfile --output $@ --make-target-prefix ""

clean:
        rm -rf ${SPACK_ENV}/spack.lock ${SPACK_ENV}/spack.mk
