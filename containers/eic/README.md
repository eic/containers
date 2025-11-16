To build the container in this directory:

```
docker buildx build -f Dockerfile --build-context spack-environment=../../spack-environment .
```

**Note:** The minimal build command shown above will assume default values for all build arguments. For this container, that means 'develop' versions for all spack repositories:
- `BUILDER_IMAGE=debian_stable_base`
- `RUNTIME_IMAGE=debian_stable_base`
- `ENV=xl`
- `BENCHMARK_COM_VERSION=master`
- `BENCHMARK_DET_VERSION=master`
- `BENCHMARK_REC_VERSION=master`
- `BENCHMARK_PHY_VERSION=master`

**Important:** Docker layer caching will not automatically update the previous checkout of these 'master' versions. To ensure you have the latest commits, you may need to use `--no-cache` or rebuild without cache.

For specific operations as used in CI builds (including custom build arguments and cache management), please refer to the GitHub and GitLab CI workflows in this repository.
