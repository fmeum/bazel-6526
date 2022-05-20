#!/bin/sh
BAZEL=${BAZEL:-bazel}
rm -rf .cache
"$BAZEL" clean
"$BAZEL" build //:transition_default --experimental_output_paths=per_action --disk_cache=.cache -s
"$BAZEL" build //:transition_different --experimental_output_paths=per_action --disk_cache=.cache -s
