# shellcheck shell=bash
# shellcheck disable=SC2034  # Variables are used by scripts that source this file
## EIC spack organization and repository, e.g. eic/eic-spack
EICSPACK_ORGREPO="eic/eic-spack"

## EIC spack commit hash or github version, e.g. v0.19.7
## note: nightly builds could use a branch e.g. releases/v0.19
## TESTING: head of eic-spack#986 (develop@dd8a73e + the MCP/opencode
## recipes); bump to the merge SHA before undrafting.
## TESTING: head of eic-spack#986 (native HTTP, no supergateway, py-* deps
## from the spack-packages#5637 cherry-pick); bump to the merge SHA before undrafting.
EICSPACK_VERSION="646ef8ccdd18ba3c69b91331c08dd50e4715210d"
