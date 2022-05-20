# Examples for `--experimental_output_paths=per_action`

## Setup

1. Clone https://github.com/fmeum/bazel/tree/per-action-path-mapping.
2. Build Bazel via `bazel build //src:bazel-dev`.
3. Export the path to the resulting Bazel binary as `BAZEL`.

## Cross-configuration cache hits

### Without `--experimental_output_paths=per_action`
```shell
$ ./compare_cache_hits.sh
...
+ bazel build //:transition_default --disk_cache=.cache
...
INFO: Elapsed time: 6.327s, Critical Path: 5.44s
INFO: 18 processes: 7 internal, 9 linux-sandbox, 2 worker.
INFO: Build completed successfully, 18 total actions
+ bazel build //:transition_different --disk_cache=.cache
...
INFO: Elapsed time: 6.909s, Critical Path: 6.60s
INFO: 18 processes: 7 internal, 9 linux-sandbox, 2 worker.
INFO: Build completed successfully, 18 total actions
```

### With `--experimental_output_paths=per_action`
```shell
$ ./compare_cache_hits.sh --experimental_output_paths=per_action
...
+ bazel build //:transition_default --disk_cache=.cache
...
INFO: Elapsed time: 16.143s, Critical Path: 5.41s
INFO: 18 processes: 7 internal, 9 linux-sandbox, 2 worker.
INFO: Build completed successfully, 18 total actions
+ bazel build //:transition_different --disk_cache=.cache
...
INFO: Elapsed time: 4.242s, Critical Path: 3.86s
INFO: 18 processes: 4 disk cache hit, 7 internal, 5 linux-sandbox, 2 worker.
INFO: Build completed successfully, 18 total actions
```

## Debug symbol support

```shell
$ ./debug_symbols.sh
+ ../bazel/bazel-bin/src/bazel-dev build //:combined --experimental_output_paths=per_action --//:dbg
Starting local Bazel server and connecting to it...
INFO: Invocation ID: 857de2c9-54dd-4771-9026-c62ba6eedc45
INFO: Analyzed target //:combined (46 packages loaded, 548 targets configured).
INFO: Found 1 target...
Target //:combined up-to-date:
  bazel-bin/combined.txt
INFO: Elapsed time: 6.206s, Critical Path: 0.48s
INFO: 6 processes: 5 disk cache hit, 1 internal.
INFO: Build completed successfully, 6 total actions
+ cat bazel-bin/combined.txt
(bazel-out/gehygcl7jezzti77pnygmxsqo-1/bin/flag_cat.txt) default_flag: (bazel-out/ugfswanubvd23laluv4u34b6b-0/bin/cat.txt) (bazel-out/cilzfbtur4tfustpqunhehjmb-0/bin/version) 0.9.0-alpha-1 simple
(bazel-out/gehygcl7jezzti77pnygmxsqo-0/bin/flag_cat.txt) different_flag: (bazel-out/ugfswanubvd23laluv4u34b6b-0/bin/cat.txt) (bazel-out/cilzfbtur4tfustpqunhehjmb-0/bin/version) 0.9.0-alpha-1 simple
combined
+ cat bazel-out/gehygcl7jezzti77pnygmxsqo-1/bin/flag_cat.txt
default_flag: (bazel-out/ugfswanubvd23laluv4u34b6b-0/bin/cat.txt) (bazel-out/cilzfbtur4tfustpqunhehjmb-0/bin/version) 0.9.0-alpha-1 simple
+ cat bazel-out/gehygcl7jezzti77pnygmxsqo-0/bin/flag_cat.txt
different_flag: (bazel-out/ugfswanubvd23laluv4u34b6b-0/bin/cat.txt) (bazel-out/cilzfbtur4tfustpqunhehjmb-0/bin/version) 0.9.0-alpha-1 simple
```
