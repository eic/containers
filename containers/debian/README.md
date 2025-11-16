To build the container in this directory:

```
docker buildx build -f Dockerfile .
```

**Note:** The minimal build command shown above will assume default values for all build arguments. For this container, that means 'develop' versions for all spack repositories:
- `SPACK_VERSION=develop`
- `SPACKPACKAGES_VERSION=develop`
- `KEY4HEPSPACK_VERSION=main`
- `EICSPACK_VERSION=develop`

**Important:** Docker layer caching will not automatically update the previous checkout of these 'develop' versions. To ensure you have the latest commits, you may need to use `--no-cache` or rebuild without cache.

For specific operations as used in CI builds (including custom build arguments and cache management), please refer to the GitHub and GitLab CI workflows in this repository.
