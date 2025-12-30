# Copilot Agent Instructions for EIC Containers Repository

This file provides comprehensive guidance for GitHub Copilot agents working on the Electron-Ion Collider (EIC) container infrastructure repository.

## Repository Overview

This repository builds and maintains multi-architecture container images for the EIC scientific software environment using:
- **Docker/OCI** for containerization
- **Spack** for scientific package management
- **GitHub Actions** for CI/CD
- **Multi-stage builds** for efficient layering

The repository produces container images available at:
- `ghcr.io/eic/debian_stable_base` - Base image with compilers and Spack
- `ghcr.io/eic/eic_ci` - Minimal CI environment
- `ghcr.io/eic/eic_xl` - Full development environment

## Architecture

### Multi-Stage Build Strategy

The build follows a **two-track approach** (builder and runtime) to ensure efficient builds while producing lightweight images:

**Builder Track:**
1. `builder_concretization_default` - Concretize default Spack environment
2. `builder_installation_default` - Build default packages
3. `builder_concretization_custom` - Concretize custom versions (e.g., specific commits)
4. `builder_installation_custom` - Build custom packages

**Runtime Track:**
1. `runtime_concretization_default` - Copy spack.lock from builder
2. `runtime_installation_default` - Install from buildcache
3. `runtime_concretization_custom` - Copy custom spack.lock
4. `runtime_installation_custom` - Install custom packages from buildcache

The builder track creates binary caches that the runtime track installs from, avoiding expensive builds in the runtime image.

### Multi-Architecture Support

All images support both `linux/amd64` and `linux/arm64` architectures through parallel builds and manifest creation.

## Key Files and Structure

```
.
├── .github/workflows/
│   ├── build-push.yml          # Main CI/CD pipeline
│   ├── docs.yml                # Documentation deployment
│   └── mirror.yaml             # Mirror synchronization
├── containers/
│   ├── debian/Dockerfile       # Base image with Spack and compilers
│   └── eic/Dockerfile          # EIC environment (multi-stage)
├── spack-environment/
│   ├── packages.yaml           # Package versions, variants, and preferences
│   ├── ci/spack.yaml           # CI environment spec
│   └── xl/spack.yaml           # Full (XL) environment spec
├── spack.sh                    # Spack core version and cherry-picks
├── spack-packages.sh           # Spack-packages version and cherry-picks
├── eic-spack.sh                # EIC-spack repository configuration
├── key4hep-spack.sh            # Key4HEP-spack repository configuration
└── docs/                       # Documentation (Docsify site)
```

## Spack Package Management

### Repository Hierarchy

Spack package definitions come from multiple repositories with **priority ordering** (highest to lowest):
1. **eic/eic-spack** - EIC-specific packages
2. **key4hep/key4hep-spack** - Key4HEP packages  
3. **spack/spack-packages** - Community packages

### Version Management

- **Default versions** are specified in `spack-environment/packages.yaml`
- **Spack core version** is set in `spack.sh`
- **Cherry-picks** from upstream Spack commits are listed in `spack.sh` and `spack-packages.sh`

### Adding Package Cherry-Picks

When adding cherry-picks to `spack-packages.sh`:
1. Add the commit hash to the `SPACKPACKAGES_CHERRYPICKS` list
2. Add a descriptive comment line with format: `## [hash]: [description]`

Example:
```bash
## 1234567: Add xrootd@5.6.9 version
1234567abcdef1234567abcdef1234567abcdef
```

### Package Version Constraints

Use the syntax `@X.Y.Z:X` to restrict packages to major version X series:
```yaml
fmt:
  require:
  - '@11.2.0:11'  # Requires fmt 11.x series
```

For open-ended constraints, use `@X.Y.Z:` format.

### Package Preferences Pattern

The `packages.yaml` uses a **dual pattern** for preferences:
```yaml
packages:
  all:
    prefer:
    - '%gcc'
    - +ipo
    require:
    - '%gcc'
    - any_of: [+ipo, '@:']
```

This is intentional because:
- `require` entries for `all` are **overwritten** by package-specific requirements
- `prefer` entries are **retained** as weaker preferences even when overridden

## Building and Testing

### Local Builds

For local builds, see `docs/building-locally.md`. The recommended approach uses:
```bash
docker buildx build --target <stage> -f containers/debian/Dockerfile .
docker buildx build --target <stage> -f containers/eic/Dockerfile .
```

Common stages:
- `builder_concretization_default` - Test concretization only
- `final` - Complete build

### CI/CD Pipeline

The GitHub Actions workflow (`build-push.yml`) runs on:
- **Schedule**: Every 6 hours
- **Push**: To `master` branch
- **Pull Request**: Against `master` branch
- **Manual**: Via workflow_dispatch

Job flow:
1. `env` - Set environment outputs
2. `base` (parallel per-arch) - Build `debian_stable_base`
3. `base-manifest` - Create multi-arch manifest
4. `eic` (parallel per-env and per-arch) - Build `eic_ci` and `eic_xl`
5. `eic-manifest` - Create multi-arch manifests

## Coding Conventions

### Docker/Dockerfile

- Use **BuildKit syntax**: `#syntax=docker/dockerfile:1.10`
- Enable **dockerfile linter checks**: `#check=error=true`
- Use **multi-stage builds** with descriptive stage names
- Leverage **BuildKit mount caches** for apt, ccache, and spack
- Use **heredoc syntax** (`<<EOF`) for multi-line RUN commands
- Set `ARG` before `FROM` for build-time variables
- Always specify **TARGETPLATFORM** for multi-arch awareness

### Shell Scripts

- Use `set -e` to exit on errors
- Use `set -x` for debugging when needed
- Prefer **heredoc** in Dockerfile RUN commands for readability
- Use **read -r -d '' VAR <<- \---** pattern for multi-line variables in bash

### YAML Configuration

- **GitLab CI**: Variables should be key-value pairs, not list items
- Use `!reference` in `before_script`/`after_script`/`rules` sections, not in `variables`
- Indent consistently (2 spaces for YAML)

### Version Tracking

- Update versions in **both** places when applicable:
  - `spack-environment/xl/epic/spack.yaml`
  - `spack-environment/cuda/epic/spack.yaml`
- Update version files (`*.sh`) for Spack repository changes
- Document version updates in commit messages

## Security Considerations

- **Never commit secrets** to the repository
- Use GitHub secrets for registry credentials
- Build caches are public; ensure no sensitive data leaks
- Validate external inputs in scripts
- Use specific commit SHAs for external dependencies when security-critical

## Testing and Validation

### Spack Environment Testing

When modifying `spack-environment/packages.yaml`:
1. Test concretization: Build `builder_concretization_default` stage
2. Check for duplicate packages (intentionally allowed: `epic`, `llvm`, `py-setuptools`, `py-urllib3`)
3. Verify no unexpected duplicates appear in concretization output

### Build Testing

- Test both architectures locally if possible (use QEMU for cross-arch)
- Verify buildcache creation and reuse
- Check final image size for unexpected growth
- Validate entrypoint and scripts work correctly

### CI Validation

- Monitor GitHub Actions workflow runs
- Check build logs for warnings
- Verify multi-arch manifest creation
- Ensure images pushed to correct registries

## Common Tasks

### Updating a Package Version

**Scenario 1**: Package updated in upstream Spack after our Spack version upgrade
- Modify `spack-environment/packages.yaml` with new version requirement

**Scenario 2**: Package updated in upstream Spack before our Spack version upgrade
- Add cherry-pick to `spack-packages.sh` with commit hash and comment
- Modify `spack-environment/packages.yaml` with new version requirement

### Adding a New Package

1. Ensure package is available in one of the Spack repositories (eic-spack, key4hep-spack, or spack-packages)
2. Add to appropriate `spack-environment/*/spack.yaml` specs list
3. Optionally add version/variant preferences to `spack-environment/packages.yaml`

### Modifying Build Arguments

1. Update ARG defaults in Dockerfile
2. Update environment variables in `.github/workflows/build-push.yml`
3. Update GitLab CI variables in `.gitlab-ci.yml` if mirroring

### Changing Compiler Versions

Supported distributions and compilers (as of last update):
- **Debian trixie**: GCC-14, Clang-20, Flang-20
- **Ubuntu noble**: GCC-14, Clang-20, Flang-20

Update in `containers/debian/Dockerfile` with version-specific logic.

## Documentation

- Documentation is built with **Docsify** from `docs/` directory
- Deployed via GitHub Pages through `docs.yml` workflow
- Update relevant documentation when making architectural changes
- Use Mermaid diagrams for visual explanations
- Keep `README.md` updated with major changes

## Git and GitHub Workflow

### Branch Naming

- Feature branches: `feature/description`
- Bug fixes: `fix/description`
- Copilot branches: `copilot/*`

### Commit Messages

- Use conventional commit format when possible: `type(scope): description`
- Examples: `build(deps): bump package`, `feat(spack): add new package`
- Reference issues: `Fixes #123` or `Closes #123`

### Pull Requests

- Ensure CI passes before merging
- Request review for significant changes
- Update documentation in the same PR as code changes
- Squash commits if many small iterations

## Buildcache Management

- Buildcache tags follow pattern: `{BUILD_IMAGE}-{GITHUB_REF_POINT_SLUG}-{arch}`
- Tags are automatically cleaned on PR close by cleanup workflows
- Buildcaches stored in GitLab registry at `eicweb.phy.anl.gov` (project ID 290)

## Additional Resources

- [EIC Software Organization](https://github.com/eic)
- [Spack Documentation](https://spack.readthedocs.io/)
- [Docker BuildKit](https://docs.docker.com/build/buildkit/)
- Internal documentation in `docs/` directory
