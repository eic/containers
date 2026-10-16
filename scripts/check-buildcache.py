#!/usr/bin/env python3
# Copyright 2026 Electron-Ion Collider
# SPDX-License-Identifier: Apache-2.0
"""Check concrete specs of a Spack environment against a binary buildcache.

Outputs missing spec DAG hashes (prefixed with '/') to stdout, separated by spaces.
Exits with 0 if all specs exist in the buildcache, or 1 if any specs are missing.
"""

import concurrent.futures
import sys

import spack.environment as ev
from spack.binary_distribution import _oci_default_tag, _oci_get_blob_info
from spack.oci.image import ImageReference


def main():
    if len(sys.argv) < 3:
        print("Usage: check-buildcache.py <env-dir> <mirror-url>", file=sys.stderr)
        sys.exit(2)

    env_dir = sys.argv[1]
    mirror_url = sys.argv[2]

    env = ev.Environment(env_dir)
    all_specs = env.all_specs()
    if not all_specs:
        print(f"No specs in environment {env_dir}", file=sys.stderr)
        sys.exit(0)

    target_image = ImageReference.from_url(mirror_url)
    print(f"Checking {len(all_specs)} specs against {mirror_url}...", file=sys.stderr)

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
        print(" ".join(hashes))
        sys.exit(1)
    else:
        print(f"All {len(all_specs)} specs already exist in buildcache.", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()
