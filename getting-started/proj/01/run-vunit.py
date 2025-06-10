#!/usr/bin/env python3

from vunit import VUnit

vu = VUnit.from_argv(compile_builtins=False, vhdl_standard='2008')
vu.add_vhdl_builtins()

lib = vu.add_library('lib')
lib.add_source_file('src/sw-to-led.vhdl')
lib.add_source_file('test/sw-to-led-tb.vhdl')

vu.main()
