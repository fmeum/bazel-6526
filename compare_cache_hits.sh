#!/bin/sh
BAZEL=${BAZEL:-bazel}
rm -rf .cache
"$BAZEL" clean
"$BAZEL" build //:transition_default --disk_cache=.cache -s "$@"
"$BAZEL" build //:transition_different --disk_cache=.cache -s "$@"
