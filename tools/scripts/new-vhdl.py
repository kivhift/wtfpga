#!/usr/bin/env python3
#
# A simple script to produce skeleton VHDL entities and VUnit test benches.

import argparse
import string

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

arg_parser = argparse.ArgumentParser(description='Create skeleton VHDL')
_a = arg_parser.add_argument
_a('-e', '--entity', help='Entity name')
_a('-t', '--test-bench', action='store_true', help='Produce a test bench')
args = arg_parser.parse_args()

if args.entity is not None:
    print(
        (test_bench if args.test_bench else entity).substitute(
            entity=args.entity
        )
    )
