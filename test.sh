#!/bin/sh
../bazel/bazel-bin/src/bazel-dev clean --expunge
../bazel/bazel-bin/src/bazel-dev shutdown
../bazel/bazel-bin/src/bazel-dev build //:transition_default //:transition_different --disk_cache=.cache/transition --build_event_publish_all_actions --build_event_json_file=transition.json
jq 'select(.id.actionCompleted.label == "//:cat")' <transition.json | jq -s length
