# Architecture Overview

The EIC container infrastructure uses a multi-stage build approach with separate builder and runtime tracks. This design ensures efficient builds while producing lightweight final images.

## Build Strategy

The container build follows a two-track approach:

```mermaid
flowchart TB
    subgraph "Builder Track"
        A[builder_image<br/>debian_stable_base] --> B[builder_concretization_default<br/>Concretize spack environment]
        B --> C[builder_installation_default<br/>Build packages]
        C --> D[builder_concretization_custom<br/>Concretize custom versions]
        D --> E[builder_installation_custom<br/>Build custom packages]
    end
    
    subgraph "Runtime Track"
        F[runtime_image<br/>debian_stable_base] --> G[runtime_concretization_default<br/>Copy spack.lock from builder]
        G --> H[runtime_installation_default<br/>Install from buildcache]
        H --> I[runtime_concretization_custom<br/>Copy custom spack.lock]
        I --> J[runtime_installation_custom<br/>Install custom from buildcache]
        J --> K[Final Image<br/>eic_ci / eic_xl]
    end
    
    C -.->|spack.lock| G
    C -.->|buildcache| H
    E -.->|spack.lock| I
    E -.->|buildcache| J
```

## Multi-Architecture Support

The infrastructure supports both `amd64` and `arm64` architectures through parallel builds:

```mermaid
flowchart LR
    subgraph "Build Phase"
        A1[Build amd64] 
        A2[Build arm64]
    end
    
    subgraph "Manifest Phase"
        M[Create Multi-Arch Manifest]
    end
    
    A1 --> D1[amd64 digest]
    A2 --> D2[arm64 digest]
    D1 --> M
    D2 --> M
    M --> R[Registry<br/>ghcr.io/eic/*]
```

## Container Layer Structure

### Base Image (debian_stable_base)

```mermaid
graph TB
    subgraph "debian_stable_base"
        D[Debian Stable Slim]
        D --> P1[System Packages<br/>git, curl, compilers, etc.]
        P1 --> G[GCC + Clang Compilers]
        G --> S[Spack Installation]
        S --> SR1[spack/spack repository]
        S --> SR2[spack/spack-packages repository]
        S --> SR3[key4hep/key4hep-spack repository]
        S --> SR4[eic/eic-spack repository]
        SR4 --> M[Spack Mirrors<br/>binaries.spack.io, ghcr.io/eic/spack-*]
    end
```

### EIC Image (eic_ci / eic_xl)

```mermaid
graph TB
    subgraph "EIC Container"
        B[debian_stable_base]
        B --> E1[Default Spack Environment<br/>ci or xl]
        E1 --> E2[Custom Environment<br/>epic, eicrecon, etc.]
        E2 --> F[Final Configuration]
        F --> BM[Benchmarks]
        F --> CP[Campaigns]
        F --> SC[Scripts & Entrypoint]
    end
```

## Spack Repository Hierarchy

The Spack package definitions come from multiple repositories with priority ordering:

```mermaid
flowchart TB
    subgraph "Priority Order (High to Low)"
        E[eic/eic-spack<br/>EIC-specific packages]
        K[key4hep/key4hep-spack<br/>Key4HEP packages]
        SP[spack/spack-packages<br/>Community packages]
    end
    
    E --> K --> SP
    
    P[Package Resolution] --> E
```

## Caching Architecture

Multiple caching layers are used to optimize build times:

```mermaid
flowchart TB
    subgraph "Build Cache Types"
        RC[Registry Cache<br/>Docker layer cache in ghcr.io]
        GC[GitHub Actions Cache<br/>ccache, apt, spack source]
        BC[Spack Buildcache<br/>Pre-built binaries on ghcr.io]
    end
    
    subgraph "Cache Locations"
        RC --> R1[ghcr.io/eic/buildcache:*]
        GC --> G1[ccache]
        GC --> G2[/var/cache/apt]
        GC --> G3[/var/cache/spack]
        BC --> B1[ghcr.io/eic/spack-v2025.07.0]
    end
```

## Environment Variants

### CI Environment (eic_ci)

Minimal environment for continuous integration:
- Core HEP packages (ROOT, Geant4, DD4hep)
- Essential reconstruction tools
- No GUI dependencies (`-opengl`, `-webgui`)

### XL Environment (eic_xl)

Full development environment:
- All CI packages plus GUI support
- Development tools (emacs, gdb, valgrind, etc.)
- Additional Python packages
- Machine learning tools (TensorFlow, PyTorch, ONNX)
- Jupyter notebook support

## Version Configuration

Package versions are controlled through several configuration files:

| File | Purpose |
|------|---------|
| `spack.sh` | Spack core version and cherry-picks |
| `spack-packages.sh` | Spack-packages version and cherry-picks |
| `key4hep-spack.sh` | Key4HEP-spack version |
| `eic-spack.sh` | EIC-spack version |
| `spack-environment/packages.yaml` | Package version preferences and variants |
