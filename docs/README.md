# EIC Container Infrastructure

Welcome to the EIC (Electron-Ion Collider) container infrastructure documentation. This documentation provides comprehensive information about the container build system, architecture, and instructions for building containers locally.

## Overview

The EIC container infrastructure provides scientific software environments for the Electron-Ion Collider project. These containers are built using Docker/OCI standards and managed through GitHub Actions, with packages installed via the [Spack](https://spack.io/) package manager.

## Quick Links

- [Architecture Overview](architecture.md) - Understanding the container build system
- [Build Pipeline](build-pipeline.md) - GitHub Actions workflow details
- [Building Locally](building-locally.md) - Instructions for local builds with caching
- [Spack Environment](spack-environment.md) - Spack configuration and packages

## Container Images

The infrastructure produces multi-architecture (amd64/arm64) container images:

| Image | Description | Registry |
|-------|-------------|----------|
| `debian_stable_base` | Base image with compilers and Spack | `ghcr.io/eic/debian_stable_base` |
| `eic_ci` | CI environment (minimal packages) | `ghcr.io/eic/eic_ci` |
| `eic_xl` | Full development environment | `ghcr.io/eic/eic_xl` |

## Getting Started

For installation instructions of `eic-shell`, see the [eic-shell repository](https://github.com/eic/eic-shell).

### Using the Container

```bash
# Pull the latest eic_xl image
docker pull ghcr.io/eic/eic_xl:latest

# Run interactively
docker run -it ghcr.io/eic/eic_xl:latest

# Or use Singularity/Apptainer
singularity pull docker://ghcr.io/eic/eic_xl:latest
singularity shell eic_xl_latest.sif
```

## Repository Structure

```
containers/
├── .github/workflows/     # GitHub Actions workflows
│   └── build-push.yml     # Main build pipeline
├── containers/
│   ├── debian/            # Base image Dockerfile
│   └── eic/               # EIC image Dockerfile
├── spack-environment/     # Spack environment configurations
│   ├── packages.yaml      # Package versions and variants
│   ├── ci/                # CI environment specs
│   └── xl/                # Full (XL) environment specs
├── spack.sh               # Spack version configuration
├── spack-packages.sh      # Spack-packages version and cherry-picks
├── eic-spack.sh           # EIC-spack repository configuration
└── key4hep-spack.sh       # Key4HEP-spack repository configuration
```

## Support

For questions or issues, please visit:
- [GitHub Issues](https://github.com/eic/containers/issues)
- [EIC Software Working Group](https://github.com/eic)
