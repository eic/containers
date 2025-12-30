# Buildcache Signature Verification

## Overview

The container build process uses Spack buildcaches to distribute pre-built binary packages. These buildcaches are signed using GPG keys to ensure integrity and authenticity.

## How It Works

### Build Process

1. **Builder Stage**: During the build, packages are compiled from source and automatically pushed to the OCI buildcache (configured in `mirrors.yaml.in` with `autopush: true` and `signed: true`)
2. **GPG Signing**: Spack automatically signs packages during autopush using the configured GPG key
3. **Public Key Export**: The public key is exported and made available to the runtime stage
4. **Runtime Stage**: The runtime stage imports the public key and verifies signatures when installing from the buildcache

### Security Layers

The buildcache security model includes multiple layers:

1. **OCI Registry Integrity**: The OCI registry (ghcr.io) provides SHA256 digest verification for all artifacts
2. **HTTPS/TLS**: All communication with the registry is encrypted
3. **Access Control**: Write access to the registry requires authentication
4. **GPG Signatures**: Packages are signed with GPG keys, providing cryptographic verification

## Production Setup (Recommended)

For production use, you should provide a persistent GPG key via GitHub Secrets. This ensures buildcaches can be verified across multiple builds.

### Generate GPG Key

```bash
# Generate a new GPG key (non-interactively)
gpg --batch --gen-key <<EOF
Key-Type: RSA
Key-Length: 4096
Name-Real: EIC Containers
Name-Email: eic-containers@github.com
Expire-Date: 0
%no-protection
%commit
EOF

# Export the key (including private key)
gpg --export-secret-keys --armor "EIC Containers" > spack-signing-key.asc
```

### Add to GitHub Secrets

1. Go to repository Settings → Secrets and variables → Actions
2. Create a new secret named `SPACK_SIGNING_KEY`
3. Paste the contents of `spack-signing-key.asc`
4. Save and delete the local `spack-signing-key.asc` file securely

### Update Workflow

Add the secret to the build step in `.github/workflows/build-push.yml`:

```yaml
secrets: |
  "CI_REGISTRY_USER=${{ secrets.GHCR_REGISTRY_USER }}"
  "CI_REGISTRY_PASSWORD=${{ secrets.GHCR_REGISTRY_TOKEN }}"
  "GITHUB_REGISTRY_USER=${{ secrets.GHCR_REGISTRY_USER }}"
  "GITHUB_REGISTRY_TOKEN=${{ secrets.GHCR_REGISTRY_TOKEN }}"
  "SPACK_SIGNING_KEY=${{ secrets.SPACK_SIGNING_KEY }}"
```

## Development/Testing Setup

For local development and testing, the build will automatically create a temporary GPG key if `SPACK_SIGNING_KEY` is not provided. This works for single builds but won't allow buildcache reuse across builds.

## Migration Notes

When enabling signature verification for existing buildcaches:

1. **Clear Old Buildcaches**: Old unsigned buildcaches may need to be cleared
2. **Transition Period**: During the transition, some builds may fail if they try to use old unsigned buildcaches
3. **Key Rotation**: If you need to rotate keys, clear the buildcache and create a new key

## Security Considerations

### Current Implementation Limitations

**⚠️ IMPORTANT SECURITY NOTICE**: The current implementation has a significant security limitation:

- **Private Key Exposure**: When a GPG private key is imported into the container (either temporary or via SPACK_SIGNING_KEY secret), it becomes embedded in the container layer
- **Public Accessibility**: Since the container base layer is published publicly, anyone can extract the private key using tools like `docker save` and layer inspection
- **Limited Authenticity**: While signatures verify package integrity (not tampered), they don't prove authenticity (who created them) since the signing key is publicly accessible
- **Attack Vector**: An attacker could extract the private key, create malicious packages, sign them with the extracted key, and users would trust them as legitimate

### Trust Model

The current GPG signature model provides:
- ✅ **Integrity verification**: Packages haven't been modified after signing
- ✅ **Transition compatibility**: Graceful migration from unsigned to signed buildcaches
- ❌ **Authenticity verification**: Cannot prove WHO signed the packages (key is public)
- ❌ **Non-repudiation**: Signatures don't prevent unauthorized signing

This is acceptable for:
- Internal use where container access is restricted
- Transition period to enable signing infrastructure
- Integrity checks within a trusted environment

This is NOT recommended for:
- Production environments requiring strong authenticity guarantees
- Public distribution with security-critical packages
- Scenarios where attackers have motivation to inject malicious packages

### Recommended Improvements for Production

For stronger security in production environments:

1. **Separate Signing from Container Build**:
   - Sign buildcaches in CI/CD environment (GitHub Actions runner) before pushing to registry
   - Only embed public key in container for verification, not private key
   - Keep private key in GitHub Secrets, never in container layers

2. **Use OCI-Native Signing**:
   - Consider using OCI registry signing mechanisms (e.g., cosign, notation)
   - These tools are designed for container/artifact signing with proper key isolation
   - Provides stronger guarantees and better key management

3. **Key Rotation**:
   - If using current approach, rotate keys regularly (e.g., every 3-6 months)
   - When rotating keys, clear old buildcaches to prevent verification failures
   - Document key rotation procedures

4. **Access Control**:
   - Limit who can modify SPACK_SIGNING_KEY secret
   - Monitor buildcache registry for unauthorized packages
   - Implement additional verification layers (e.g., checksums, dependency scanning)

### Current Best Practices

While the current implementation has limitations:

- **Key Protection**: Store keys in GitHub Secrets, never commit to repository
- **Key Rotation**: Rotate GPG keys periodically (recommended: every 3-6 months)
- **Buildcache Clearing**: When rotating keys, clear old buildcaches to prevent signature verification failures
- **Monitoring**: Monitor for suspicious packages or signature verification failures
- **Documentation**: Clearly communicate the security model to users

## Troubleshooting

### Signature Verification Failures

If you see errors like:
```
==> Error: Unable to verify buildcache package
```

Possible causes:
- The buildcache was signed with a different key
- The public key wasn't properly imported
- The buildcache is from before signing was enabled

Solutions:
- Clear the buildcache and rebuild
- Ensure SPACK_SIGNING_KEY secret is configured
- Check that the public key is being exported and imported correctly

### Temporary Key Issues

If builds are failing because they can't reuse buildcaches:
- Add the SPACK_SIGNING_KEY secret with a persistent key
- Or, clear buildcaches between builds
