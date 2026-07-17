#!/usr/bin/env python3

# If you are running under a venv and having issues on Windows, remove the
# shebang. The Python launcher on Windows is a little too smart for its own
# good. When it's called with the script as its first argument, it inspects the
# script to see if it contains a shebang line and then tries to find an
# appropriate interpreter based on some magic if it does. Having "/usr/bin/env
# python3" along with a venv lead to too much confusion since the launcher
# didn't find a python3 on the venv path since there is only python. It then
# tried other directories on the path and found another python3, using that. Of
# course, that version of python3 did not have vunit installed...

import os
import pathlib
import sys

if sys.version_info < (3, 11):
    import tomli as tomllib
else:
    import tomllib

from vunit import VUnit, VUnitCLI

# We want this script to the somewhat generic and usable with our tool setup.
# So, we'll check for our own environment variables, etc., to be able to
# override defaults and the like.
cli = VUnitCLI()
_a = cli.parser.add_argument
_a(
    '--rv-src-file',
    default='vunit-src.toml',
    help='TOML file with source globs',
)
args = cli.parse_args()

env = os.environ
args.output_path = env.get('RV_VUNIT_OUTPUT_PATH') or args.output_path
args.rv_src_file = env.get('RV_SRC_FILE') or args.rv_src_file

# Oddly, there are ghdl-specific arguments that can be passed. To more-easily
# be able to automatically add signals to the viewer when requesting a GUI,
# we'll parse things and tweak the argparse NameSpace object to specify VCD as
# the output format. According to the docs, there is no way to specify this via
# a simulation option. (GTKWave presents the names more succinctly when dealing
# with VCDs vs the default.) If we're using Questa or something else, tweaking
# this shouldn't hurt...
if args.gui:
    args.gtkwave_fmt = 'vcd'

# The current default standard is 2008. Explicitly specify it anyway. Also set
# `compile_builtins` to false. Otherwise, VUnit complains about that option's
# upcoming deprecation.
vu = VUnit.from_args(args, compile_builtins=False, vhdl_standard='2008')
vu.add_vhdl_builtins()

lib = vu.add_library('lib')


def get_source_globs(cfg_file=None):
    if cfg_file is None:
        return 'src/*.vhdl test/*.vhdl'.split()

    # Make sure it's a Path(). This does nothing if it is.
    cfg_file = pathlib.Path(cfg_file)
    if not cfg_file.exists():
        raise ValueError(f'Given config file does not exist: {cfg_file}')

    with cfg_file.open('rb') as fin:
        cfg = tomllib.load(fin)

    return cfg.get('source', list())


src_file = pathlib.Path(args.rv_src_file)
for glob in get_source_globs(src_file if src_file.exists() else None):
    lib.add_source_files(glob)

if args.gui:
    # It's tedious to have to add signals for viewing when the simulation
    # viewer is started. So, depending on the simulator, we make configuration
    # adjustments and write out some TCL to assist in adding signals of
    # interest. At the time of writing, only QuestaSim and GHDL/GTKWave are
    # available for use and automation development/testing.
    #
    # There is a Python package from Western Digital called pyvcd that can be
    # used to parse VCD files. Using this package along with the `post_check`
    # callbacks that are available on VUnit TestBench objects was explored
    # since this would have been more general. Unfortunately, VUnit only calls
    # the callback after the viewer is finished but we need to examine the VCD
    # and write out a signal-addition script prior to the viewer executing.
    # Thus, we have to resort to TCL executed by the viewer itself.
    def write_script_and_options(path, script, comp_opts=None, sim_opts=None):
        if not path.exists():
            with path.open(mode='w') as fout:
                fout.write(script)

        for args in comp_opts or list():
            vu.set_compile_option(*args)

        for args in sim_opts or list():
            vu.set_sim_option(*args)

    gtkwave_script = r'''set nfacs [gtkwave::getNumFacs]
set to_add [list]
for {set i 0} {$i < $nfacs} {incr i} {
    set facname [gtkwave::getFacName $i]
    if [regexp {^[0-9_a-z]+_tb\..+\..+$} $facname] {
        lappend to_add $facname
    }
}
gtkwave::addSignalsFromList [lsort -dictionary $to_add]
gtkwave::/Time/Zoom/Zoom_Full
'''

    modelsim_script = r'''set to_add [list]
foreach sig [find signals -r /*_tb/*] {
    if [regexp {^/[0-9_a-z]+_tb/.+/.+$} $sig] {
        lappend to_add $sig
    }
}
configure wave -signalnamewidth 1
foreach sig [lsort -dictionary $to_add] {
    add wave $sig
}
run -all
wave zoom full
'''

    sim_name = vu.get_simulator_name()
    if sim_name is not None:
        vunit_out = pathlib.Path(args.output_path)
        if 'ghdl' == sim_name:
            script_path = vunit_out / 'add-gtkwave-signals.tcl'
            write_script_and_options(
                script_path,
                gtkwave_script,
                sim_opts=(('ghdl.gtkwave_script.gui', str(script_path)),),
            )
        elif 'modelsim' == sim_name:
            script_path = vunit_out / 'add-modelsim-signals.tcl'
            write_script_and_options(
                script_path,
                modelsim_script,
                comp_opts=(('modelsim.vcom_flags', '+acc=npr'.split()),),
                sim_opts=(
                    ('modelsim.vsim_flags.gui', '-debugDB'.split()),
                    ('modelsim.init_file.gui', str(script_path)),
                    # These are not available in 4.7.0 but are currently listed
                    # in the on-line docs. Maybe eventually we'll run vopt
                    # between vcom and vsim...
                    # ('modelsim.three_step_flow', True),
                    # ('modelsim.vopt_flags', '+acc=npr'.split()),
                ),
            )

vu.main()
