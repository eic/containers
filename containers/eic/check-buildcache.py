#!/usr/bin/env python3
"""Check concrete specs of a Spack environment against binary buildcaches.

Ignores external packages (which cannot be built by Spack).
Outputs missing spec DAG hashes (prefixed with '/') to output-file (or stdout).
Exits with 0 on success, or non-zero on error.
"""

import concurrent.futures
import sys

import spack.environment as ev
import spack.mirrors.mirror
from spack.binary_distribution import _oci_default_tag, _oci_get_blob_info
from spack.oci.image import ImageReference, is_oci_url


def main():
    if len(sys.argv) < 2:
        print("Usage: check-buildcache.py <env-dir> [mirror-url] [output-file]", file=sys.stderr)
        sys.exit(2)

    env_dir = sys.argv[1]
    mirror_url = None
    output_file = None

    if len(sys.argv) == 3:
        if any(sys.argv[2].startswith(p) for p in ("oci://", "http://", "https://", "file://")):
            mirror_url = sys.argv[2]
        else:
            output_file = sys.argv[2]
    elif len(sys.argv) >= 4:
        mirror_url = sys.argv[2]
        output_file = sys.argv[3]

    env = ev.Environment(env_dir)
    # Ignore external specs as they are pre-installed on the host / not built
    all_specs = [s for s in env.all_specs() if not s.external]
    if not all_specs:
        print(f"No non-external specs in environment {env_dir}", file=sys.stderr)
        if output_file:
            open(output_file, "w").close()
        sys.exit(0)

    if mirror_url:
        mirror_urls = [mirror_url]
    else:
        mirrors = [
            m for m in spack.mirrors.mirror.MirrorCollection(binary=True).values()
            if getattr(m, "autopush", False)
        ]
        if not mirrors:
            mirrors = list(spack.mirrors.mirror.MirrorCollection(binary=True).values())
        mirror_urls = [m.fetch_url for m in mirrors]

    oci_mirrors = [u for u in mirror_urls if is_oci_url(u)]
    if not oci_mirrors:
        print(f"No OCI binary mirrors found in {mirror_urls}", file=sys.stderr)
        sys.exit(1)

    target_images = [ImageReference.from_url(u) for u in oci_mirrors]
    print(
        f"Checking {len(all_specs)} non-external specs against {', '.join(oci_mirrors)}...",
        file=sys.stderr,
    )

    def is_missing(spec):
        tag = _oci_default_tag(spec)
        for img in target_images:
            ref = img.with_tag(tag)
            if _oci_get_blob_info(ref) is not None:
                return spec, False
        return spec, True

    missing = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=16) as pool:
        for spec, missing_flag in pool.map(is_missing, all_specs):
            if missing_flag:
                missing.append(spec)

    if missing:
        print(f"Found {len(missing)} missing spec(s) that need to be built:", file=sys.stderr)
        for s in missing:
            print(f"  - {s.short_spec} (/{s.dag_hash()})", file=sys.stderr)
        hashes = [f"/{s.dag_hash()}" for s in missing]
        hashes_str = " ".join(hashes)
        if output_file:
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(hashes_str + "\n")
        else:
            print(hashes_str)
        sys.exit(0)
    else:
        print(f"All {len(all_specs)} specs already exist in buildcache.", file=sys.stderr)
        if output_file:
            open(output_file, "w").close()
        sys.exit(0)


if __name__ == "__main__":
    main()
