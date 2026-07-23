#!/usr/bin/env python3

'''
The purpose of this script is to produce skeleton VHDL entities and VUnit test
benches. The aim is to reduce friction and boilerplate when working on new
code. The given entity name will be used directly for both entities and test
benches. If file output is requested, the file name will be derived from the
given entity name (<entity>[-tb].vhdl) unless one is explicitly given.
'''

import argparse
import contextlib
import pathlib
import string
import sys


class HelpFormatter(
    argparse.ArgumentDefaultsHelpFormatter, argparse.RawTextHelpFormatter
): ...


entity = string.Template('''\
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity ${entity} is
    -- generic (
    -- );
    port (
        clk, rst: in std_logic;
        d: in std_logic_vector(7 downto 0);
        q: out std_logic_vector(7 downto 0)
    );
end;

architecture rtl of ${entity} is
    signal reg_d, reg_q: std_logic_vector(q'range);
begin
    -- register
    process (clk, rst)
    begin
        if rst then
            reg_q <= (others => '0');
        elsif rising_edge(clk) then
            reg_q <= reg_d;
        end if;
    end process;
end;\
''')

test_bench = string.Template('''\
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity ${entity}_tb is
    generic (runner_cfg: string);
end;

architecture tb of ${entity}_tb is
    constant CLK_PERIOD: time := 10 ns;

    signal clk, rst: std_logic := '1';
    signal d, q: std_logic_vector(7 downto 0);
begin
    clk <= not clk after CLK_PERIOD / 2;

UUT:
    entity work.${entity}(rtl)
        -- generic map (
        -- )
        port map (
            clk => clk,
            rst => rst,
            d => d,
            q => q
        );

    process
    begin
        test_runner_setup(runner, runner_cfg);

        wait for 3 * CLK_PERIOD;
        rst <= '0';

        wait for 50 * CLK_PERIOD;

        test_runner_cleanup(runner);
    end process;
end;\
''')

arg_parser = argparse.ArgumentParser(
    description='Create new-entity skeleton VHDL',
    epilog=__doc__,
    formatter_class=HelpFormatter,
)
_a = arg_parser.add_argument
_a('-e', '--entity', help='Entity name')
_a('-t', '--test-bench', action='store_true', help='Produce a test bench')
_a(
    '-w',
    '--write',
    const=True,
    nargs='?',
    help='Write to path derived from entity name or given one',
)
_a('--clobber', action='store_true', help='Clobber output file if extant')
args = arg_parser.parse_args()

if args.entity is None:
    arg_parser.print_help()
    sys.exit(0)

if args.write is None:
    output = contextlib.nullcontext(sys.stdout)
else:
    if args.write is True:
        output_path = pathlib.Path(
            f'{args.entity.replace("_", "-")}'
            f'{"-tb" if args.test_bench else ""}.vhdl'
        )
    else:
        output_path = pathlib.Path(args.write)

    if output_path.exists() and not args.clobber:
        raise SystemExit(f'Not clobbering {output_path}')

    output = output_path.open('w')

template = test_bench if args.test_bench else entity
with output as outf:
    print(template.substitute(entity=args.entity), file=outf)
