#!/usr/bin/env python3
# Copyright 2026 Electron-Ion Collider
# SPDX-License-Identifier: Apache-2.0
"""Check concrete specs of a Spack environment against a binary buildcache.

Ignores external packages (which cannot be built by Spack).
Outputs missing spec DAG hashes (prefixed with '/') to output-file (or stdout).
Exits with 0 if all specs exist in the buildcache, or 1 if any specs are missing.
"""

import concurrent.futures
import sys

import spack.environment as ev
from spack.binary_distribution import _oci_default_tag, _oci_get_blob_info
from spack.oci.image import ImageReference


def main():
    if len(sys.argv) < 3:
        print("Usage: check-buildcache.py <env-dir> <mirror-url> [output-file]", file=sys.stderr)
        sys.exit(2)

    env_dir = sys.argv[1]
    mirror_url = sys.argv[2]
    output_file = sys.argv[3] if len(sys.argv) > 3 else None

    env = ev.Environment(env_dir)
    # Ignore external specs as they are pre-installed on the host / not built
    all_specs = [s for s in env.all_specs() if not s.external]
    if not all_specs:
        print(f"No non-external specs in environment {env_dir}", file=sys.stderr)
        if output_file:
            open(output_file, "w").close()
        sys.exit(0)

    target_image = ImageReference.from_url(mirror_url)
    print(f"Checking {len(all_specs)} non-external specs against {mirror_url}...", file=sys.stderr)

    def is_missing(spec):
        tag = _oci_default_tag(spec)
        ref = target_image.with_tag(tag)
        blob = _oci_get_blob_info(ref)
        return spec, (blob is None)

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
        sys.exit(1)
    else:
        print(f"All {len(all_specs)} specs already exist in buildcache.", file=sys.stderr)
        if output_file:
            open(output_file, "w").close()
        sys.exit(0)


if __name__ == "__main__":
    main()
