# Build Pipeline

The container build pipeline is implemented as a GitHub Actions workflow. This document describes the workflow structure and job dependencies.

## Workflow Overview

```mermaid
flowchart TB
    subgraph "Triggers"
        T1[Schedule<br/>Every 6 hours]
        T2[Push to master]
        T3[Pull Request to master]
        T4[Manual Dispatch]
    end
    
    T1 & T2 & T3 & T4 --> W[build-push workflow]
    
    subgraph "Jobs"
        W --> B1[base amd64]
        W --> B2[base arm64]
        B1 & B2 --> BM[base-manifest]
        BM --> E1[eic_ci amd64]
        BM --> E2[eic_ci arm64]
        BM --> E3[eic_xl amd64]
        BM --> E4[eic_xl arm64]
        E1 & E2 --> EM1[eic-manifest ci]
        E3 & E4 --> EM2[eic-manifest xl]
    end
```

## Job Details

### Base Image Job

Builds the `debian_stable_base` image with Spack and compilers installed.

```mermaid
sequenceDiagram
    participant GH as GitHub Actions
    participant R as Registry (ghcr.io)
    participant C as Cache
    
    GH->>GH: Checkout repository
    GH->>GH: Load spack versions<br/>from *.sh files
    GH->>GH: Setup Docker Buildx
    GH->>C: Restore build mount caches<br/>apt, spack source
    GH->>R: Login to registry
    GH->>GH: Build Dockerfile
    Note over GH: containers/debian/Dockerfile
    GH->>R: Push image by digest
    GH->>R: Push layer cache
    GH->>C: Save build mount caches
    GH->>GH: Upload digest artifact
```

**Key Build Arguments:**
- `SPACK_ORGREPO`, `SPACK_VERSION`, `SPACK_SHA`, `SPACK_CHERRYPICKS`
- `SPACKPACKAGES_ORGREPO`, `SPACKPACKAGES_VERSION`, `SPACKPACKAGES_SHA`, `SPACKPACKAGES_CHERRYPICKS`
- `KEY4HEPSPACK_ORGREPO`, `KEY4HEPSPACK_VERSION`, `KEY4HEPSPACK_SHA`
- `EICSPACK_ORGREPO`, `EICSPACK_VERSION`, `EICSPACK_SHA`

### Base Manifest Job

Creates a multi-architecture manifest from the per-architecture digests.

```mermaid
sequenceDiagram
    participant GH as GitHub Actions
    participant R as Registry (ghcr.io)
    
    GH->>GH: Download digest artifacts
    GH->>R: Login to registry
    GH->>GH: Compute metadata tags
    GH->>R: Create manifest list<br/>combining amd64 + arm64
```

**Output Tags:**
- `pipeline-{run_id}` - Internal tag for CI chaining
- `unstable-pr-{number}` - For pull requests
- Version tags for releases

### EIC Image Job

Builds the full EIC environment image on top of the base image.

```mermaid
sequenceDiagram
    participant GH as GitHub Actions
    participant R as Registry (ghcr.io)
    participant C as Cache
    
    GH->>GH: Free disk space
    GH->>GH: Checkout repository
    GH->>GH: Resolve benchmark SHAs
    GH->>GH: Resolve campaign SHAs
    GH->>GH: Generate mirrors.yaml
    GH->>GH: Setup Docker Buildx
    GH->>C: Restore build mount caches<br/>ccache, spack source
    GH->>R: Login to registry
    GH->>GH: Build multi-stage Dockerfile
    Note over GH: containers/eic/Dockerfile
    GH->>R: Push image by digest
    GH->>R: Push layer cache
    GH->>C: Save build mount caches
    GH->>GH: Upload digest artifact
```

**Key Build Arguments:**
- `ENV` - Environment type (`ci` or `xl`)
- `INTERNAL_TAG` - Base image tag to build from
- Benchmark SHAs for common_bench, detector_benchmarks, etc.
- Campaign SHAs for simulation_campaign_hepmc3, job_submission_*, etc.

**Secret Mounts:**
- `mirrors.yaml` - Spack buildcache configuration with credentials

### EIC Manifest Job

Creates multi-architecture manifests for each environment variant.

## Caching Strategy

### Docker Layer Cache

Stored in the registry using the `cache-to` and `cache-from` build options:

```yaml
cache-from: |
  type=registry,ref=ghcr.io/eic/buildcache:{image}-{branch}-{arch}
cache-to: type=registry,ref=ghcr.io/eic/buildcache:{image}-{branch}-{arch},mode=max
```

**Buildcache Cleanup**: When a pull request is closed or merged, the `cleanup-buildcache` workflow automatically removes all buildcache tags associated with that PR from both ghcr.io and eicweb.phy.anl.gov registries. This prevents buildcache accumulation and keeps the registries clean.

### Build Mount Cache

Uses [buildkit-cache-dance](https://github.com/reproducible-containers/buildkit-cache-dance) to persist mount caches:

| Cache | Path | Contents |
|-------|------|----------|
| `var-cache-apt` | `/var/cache/apt` | APT package cache |
| `var-lib-apt` | `/var/lib/apt` | APT lists cache |
| `var-cache-spack` | `/var/cache/spack` | Spack source tarballs |
| `ccache` | `/ccache` | Compiler cache |

### Spack Buildcache

Pre-built binaries are stored in OCI registries:

- **Read-only**: `oci://ghcr.io/eic/spack-{version}` - Public buildcache
- **Write**: Configured via secret `mirrors.yaml` mount during builds

## Workflow Triggers

### build-push workflow

| Trigger | Behavior |
|---------|----------|
| Schedule (cron) | Every 6 hours - nightly builds |
| Push to master | Build and push with `pipeline-*` tag |
| Pull Request | Build with `unstable-pr-*` tag |
| Manual Dispatch | Allows overriding EDM4EIC, EICRECON, JUGGLER versions |

### cleanup-buildcache workflow

| Trigger | Behavior |
|---------|----------|
| Pull Request closed | Automatically removes all buildcache tags associated with the branch slug (typically unique to the PR) from ghcr.io and eicweb.phy.anl.gov |
| Manual Dispatch | Allows manual cleanup of buildcache tags for a specific branch or PR by specifying a custom `ref_slug` parameter |

## Environment Matrix

The EIC job builds the following matrix:

| ENV | Architecture | Description |
|-----|--------------|-------------|
| ci | amd64 | CI environment for x86_64 |
| ci | arm64 | CI environment for ARM64 |
| xl | amd64 | Full environment for x86_64 |
| xl | arm64 | Full environment for ARM64 |

## Concurrency Control

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: false
```

Workflows are grouped by PR number or branch, but **not cancelled** when new commits are pushed (builds are expensive and take hours).
