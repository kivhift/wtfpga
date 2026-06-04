library ieee;
    use ieee.std_logic_1164.all, ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity pulse_width_modulation_tb is
    generic (runner_cfg: string);
end;

architecture tb of pulse_width_modulation_tb is
    constant CLK_PERIOD: time := 10 ns;

    signal clk, rst, en: std_logic := '1';
    signal output: std_logic;
begin
    clk <= not clk after CLK_PERIOD / 2;

DUT:
    entity work.pulse_width_modulation(rtl)
        generic map (
            PERIOD => 10,
            DUTY => 3
        )
        port map (
            clk => clk,
            rst => rst,
            en => en,
            output => output
        );

    process
    begin
        test_runner_setup(runner, runner_cfg);

        wait for 3 * CLK_PERIOD;
        rst <= '0';

        wait for 50 * CLK_PERIOD;

        en <= '0';
        wait for 50 * CLK_PERIOD;

        en <= '1';
        wait for 50 * CLK_PERIOD;

        test_runner_cleanup(runner);
    end process;
end;

