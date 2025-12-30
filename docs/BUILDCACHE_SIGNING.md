# Buildcache Signature Verification

## Overview

The container build process uses Spack buildcaches to distribute pre-built binary packages. These buildcaches are signed using GPG keys to ensure integrity and authenticity.

**SECURITY MODEL**: The GPG private key is **NEVER** stored in container layers. It is provided as a Docker secret during build and mounted only when needed for signing operations. Only the public key is embedded in the container for verification purposes.

## How It Works

### Build Process

1. **Base Layer Setup**: 
   - GPG private key is provided via SPACK_SIGNING_KEY secret (required)
   - Public key is extracted and stored at `${SPACK_ROOT}/spack-public-key.pub`
   - Private key is NOT persisted in any container layer

2. **Builder Stage**: 
   - During package compilation, the private key is mounted as a secret
   - Packages are compiled from source and automatically pushed to OCI buildcache
   - Spack autopush signs packages using the mounted private key
   - Private key is only available during the RUN step, not in final layer

3. **Runtime Stage**: 
   - Only the public key (from base layer) is available
   - Signatures are verified when installing from buildcache
   - Private key is never present in runtime containers

### Security Layers

The buildcache security model provides:

1. **GPG Signatures**: Cryptographic signing with private key stored externally (GitHub Secrets)
2. **Key Isolation**: Private key never embedded in container layers, only mounted during build
3. **Authenticity Verification**: Signatures prove packages were signed by holder of private key
4. **OCI Registry Integrity**: SHA256 digest verification for all artifacts
5. **HTTPS/TLS**: Encrypted communication with the registry
6. **Access Control**: Write access to the registry requires authentication

## Production Setup (Required)

A persistent GPG key **MUST** be provided via GitHub Secrets. There is no fallback - builds will fail without this secret.

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

**NOTE**: The SPACK_SIGNING_KEY secret is now **REQUIRED**. Builds will fail if not provided.

## Security Considerations

### Security Model

**✅ SECURE IMPLEMENTATION**: The private key is **NEVER** stored in container layers.

**Key Security Features:**
- **Private Key Isolation**: Stored only in GitHub Secrets, never in container filesystem
- **Secret Mounting**: Private key is mounted during build steps that need signing, then discarded
- **Public Key Only**: Container layers contain only the public key for verification
- **No Extraction Risk**: Private key cannot be extracted from published containers
- **Strong Authenticity**: Signatures prove packages were signed by holder of the secret private key

### Trust Model

The GPG signature model provides:
- ✅ **Integrity verification**: Packages haven't been modified after signing
- ✅ **Authenticity verification**: Packages signed by holder of private key in GitHub Secrets
- ✅ **Non-repudiation**: Only authorized CI/CD with access to secret can sign packages
- ✅ **Key Protection**: Private key never exposed in public container layers
- ✅ **Transition compatibility**: Graceful migration from unsigned to signed buildcaches

### How It Works

1. **Private Key Storage**: Stored securely in GitHub Secrets (SPACK_SIGNING_KEY)
2. **Build-Time Mounting**: 
   - Private key mounted as Docker secret during builder RUN steps
   - Used for signing packages during autopush
   - Exists only in memory during RUN, never written to filesystem layer
3. **Public Key Embedding**: 
   - Public key extracted and stored at `${SPACK_ROOT}/spack-public-key.pub`
   - Safe to include in public containers (used only for verification)
4. **Verification**: Runtime containers use embedded public key to verify signatures

### Key Protection

- **GitHub Secrets**: Private key encrypted at rest in GitHub's secure storage
- **Limited Access**: Only authorized repository collaborators can modify secrets
- **Audit Trail**: GitHub tracks who accesses and modifies secrets
- **No Container Exposure**: Private key never persisted in any Docker layer
- **Temporary Usage**: Private key exists only during RUN execution, then removed

### Key Rotation

When rotating keys:

1. Generate new GPG key (see instructions above)
2. Update SPACK_SIGNING_KEY secret in GitHub
3. Clear old buildcaches (signed with old key)
4. Rebuild containers to generate new signed buildcaches
5. Securely delete old private key

Recommended rotation frequency: Every 6-12 months or when:
- Key may have been compromised
- Team member with key access leaves
- As part of regular security hygiene

### Best Practices

- **Key Protection**: Store private key only in GitHub Secrets, never commit to repository or share
- **Access Control**: Limit who can view/modify SPACK_SIGNING_KEY secret in repository settings
- **Key Rotation**: Rotate GPG keys periodically (recommended: every 6-12 months)
- **Buildcache Clearing**: When rotating keys, clear old buildcaches signed with previous key
- **Monitoring**: Monitor for suspicious packages or signature verification failures
- **Audit**: Review GitHub Actions logs for unauthorized build attempts

## Troubleshooting

### Build Fails: SPACK_SIGNING_KEY Required

If you see:
```
ERROR: SPACK_SIGNING_KEY secret is required but not provided
```

Solution:
- The secret is mandatory - generate a GPG key and add it to GitHub Secrets
- Follow the "Production Setup" instructions above
- Ensure the secret is named exactly `SPACK_SIGNING_KEY`

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
- Ensure SPACK_SIGNING_KEY secret is configured correctly
- Check that the public key is being exported and imported correctly
- Verify key consistency across builds
