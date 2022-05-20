#!/bin/sh
BAZEL=${BAZEL:-bazel}
set -x
"$BAZEL" build //:combined --experimental_output_paths=per_action --//:dbg "$@"
cat bazel-bin/combined.txt
cat bazel-out/gehygcl7jezzti77pnygmxsqo-1/bin/flag_cat.txt
cat bazel-out/gehygcl7jezzti77pnygmxsqo-0/bin/flag_cat.txt
