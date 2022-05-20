BuildSettingInfo = provider(fields = ["value"])

def _bool_flag_impl(ctx):
    return BuildSettingInfo(value = ctx.build_setting_value)

bool_flag = rule(
    implementation = _bool_flag_impl,
    build_setting = config.bool(flag = True),
)

PATH_MAPPING = {"supports-path-mapping": ""}
MATERIALIZED_INPUT_PATHS = {"requires-materialized-input-paths": ""}

def _print_version_impl(ctx):
    out = ctx.actions.declare_file(ctx.attr.name)

    args = ctx.actions.args()
    args.add(out)

    ctx.actions.run(
        outputs = [out],
        executable = ctx.executable._version,
        arguments = [args],
        mnemonic = "Version",
        progress_message = "Writing %{output}",
        execution_requirements = PATH_MAPPING,
    )

    return DefaultInfo(files = depset([out]))

print_version = rule(
    implementation = _print_version_impl,
    attrs = {
        "_version": attr.label(
            default = "//tools:version",
            executable = True,
            cfg = "exec",
        ),
    },
)

def _map_cat_arg(file, _dir_expander, path_mapper):
    return "{}={}".format(file.short_path, path_mapper.path(file))

def _cat_impl(ctx):
    is_dbg = ctx.attr._is_dbg[BuildSettingInfo].value

    args = ctx.actions.args()
    args.add(ctx.outputs.out)
    args.add_all(depset(ctx.files.srcs), map_each = _map_cat_arg, format_each = "<%s")
    args.add(ctx.attr.string + "\n")

    execution_requirements = {}
    execution_requirements.update(PATH_MAPPING)
    if is_dbg:
        execution_requirements.update(MATERIALIZED_INPUT_PATHS)

    ctx.actions.run(
        outputs = [ctx.outputs.out],
        inputs = ctx.files.srcs,
        executable = ctx.executable._cat,
        arguments = [args],
        env = {"DEBUG": "1"} if is_dbg else None,
        mnemonic = "Cat",
        progress_message = "Writing %{output}",
        execution_requirements = execution_requirements,
    )
    return [DefaultInfo(files = depset([ctx.outputs.out]))]

cat = rule(
    implementation = _cat_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "string": attr.string(mandatory = True),
        "out": attr.output(mandatory = True),
        "_cat": attr.label(
            default = "//tools:Cat",
            executable = True,
            cfg = "exec",
        ),
        "_is_dbg": attr.label(default = Label("//:dbg")),
    },
)

FlagProvider = provider(fields = ["value"])

def _flag_impl(ctx):
    return FlagProvider(value = ctx.build_setting_value)

flag = rule(
    implementation = _flag_impl,
    build_setting = config.string(flag = True),
)

def _flag_cat_impl(ctx):
    prefix = ctx.attr._flag[FlagProvider].value + ": "
    is_dbg = ctx.attr._is_dbg[BuildSettingInfo].value

    args = ctx.actions.args()
    args.use_param_file("@%s", use_always = True)
    args.add(ctx.outputs.out)
    args.add_all(
        ctx.files.srcs,
        before_each = prefix,
        format_each = "<%s",
    )
    args.add(prefix + ctx.attr.string + "\n")

    execution_requirements = {}
    execution_requirements.update(PATH_MAPPING)
    if is_dbg:
        execution_requirements.update(MATERIALIZED_INPUT_PATHS)

    ctx.actions.run(
        outputs = [ctx.outputs.out],
        inputs = ctx.files.srcs,
        executable = ctx.executable._cat,
        arguments = [args],
        env = {"DEBUG": "1"} if is_dbg else None,
        mnemonic = "Cat",
        progress_message = "Writing %{output} with prefix",
        execution_requirements = execution_requirements,
    )
    return [DefaultInfo(files = depset([ctx.outputs.out]))]

flag_cat = rule(
    _flag_cat_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "string": attr.string(mandatory = True),
        "out": attr.output(mandatory = True),
        "_cat": attr.label(
            default = "//tools:Cat",
            executable = True,
            cfg = "exec",
        ),
        "_flag": attr.label(default = Label("//:flag")),
        "_is_dbg": attr.label(default = Label("//:dbg")),
    },
)

def _flag_transition_impl(settings, attr):
    return {"//:flag": attr.flag}

flag_transition = transition(
    implementation = _flag_transition_impl,
    inputs = [],
    outputs = ["//:flag"],
)

def _flag_files_impl(ctx):
    files = ctx.files.srcs
    return [DefaultInfo(
        files = depset(direct = files),
    )]

flag_files = rule(
    _flag_files_impl,
    attrs = {
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
        ),
        "flag": attr.string(),
        "srcs": attr.label_list(allow_files = True),
    },
    cfg = flag_transition,
)
