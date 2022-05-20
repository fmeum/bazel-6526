#!/bin/sh
BAZEL=${BAZEL:-bazel}
set -x
rm -rf .cache
"$BAZEL" clean
"$BAZEL" build //:transition_default --disk_cache=.cache "$@"
"$BAZEL" build //:transition_different --disk_cache=.cache "$@"
