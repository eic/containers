# GitHub Copilot Instructions

This repository builds container images for the Electron-Ion Collider (EIC) scientific software environment.

## Primary Reference

**For comprehensive guidance, see [`AGENTS.md`](../AGENTS.md) in the repository root.**

The `AGENTS.md` file contains detailed information about:
- Repository architecture and build strategy
- Spack package management conventions
- Docker multi-stage build patterns
- Coding conventions for Dockerfiles, shell scripts, and YAML
- Common tasks and workflows
- Testing and validation procedures

## Quick Reference

### Key Technologies

- **Spack** - Scientific package manager
- **Docker/OCI** - Multi-stage, multi-architecture container builds
- **GitHub Actions** - CI/CD pipeline
- **BuildKit** - Advanced Docker build features with caching

### Essential Commands

```bash
# Build stages locally
docker buildx build --target builder_concretization_default -f containers/eic/Dockerfile .
docker buildx build --target final -f containers/eic/Dockerfile .

# Spack environment activation
spack env activate --dir <path>
```

### File Modification Guidelines

When modifying files, follow these patterns:

**`spack-environment/packages.yaml`**
- Use `@X.Y.Z:X` syntax for major version constraints
- Maintain both `prefer` and `require` sections in `packages:all`
- Use `any_of: [+variant, '@:']` pattern for optional variants

**`spack-packages.sh`**
- Add cherry-pick commit hashes with descriptive comment: `## [hash]: [description]`

**Dockerfiles**
- Use BuildKit syntax: `#syntax=docker/dockerfile:1.10`
- Enable checks: `#check=error=true`
- Use heredoc for multi-line RUN: `RUN <<EOF ... EOF`
- Leverage mount caches for performance

### Version Updates

When updating package versions:
1. Check if cherry-pick needed in `spack-packages.sh`
2. Update version in `spack-environment/packages.yaml`
3. Update in **both** `xl` and `cuda` subdirectories if epic-related

### Testing Changes

Before submitting:
1. Test concretization with builder stage builds
2. Verify no unexpected duplicate packages
3. Check CI workflow passes
4. Update documentation if architecture changes

## Registry Information

Images are published to:
- **GitHub Container Registry**: `ghcr.io/eic/*`
- **DockerHub** (optional): `docker.io/eicweb/*`

Buildcache stored at:
- **GitLab Registry**: `eicweb.phy.anl.gov/containers/eic_container`

## Support

For detailed documentation, see the `docs/` directory or visit the [GitHub repository](https://github.com/eic/containers).
