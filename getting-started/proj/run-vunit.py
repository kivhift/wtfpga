#!/usr/bin/env python3

from vunit import VUnit

# The current default standard is 2008. Explicitly specify it anyway.
vu = VUnit.from_argv(compile_builtins=False, vhdl_standard='2008')
vu.add_vhdl_builtins()

lib = vu.add_library('lib')

# There are only six projects with no extraneous source. Just be lazy and slurp
# up everything.
lib.add_source_files('0*/src/*.vhdl')
lib.add_source_files('0*/test/*.vhdl')

vu.main()
