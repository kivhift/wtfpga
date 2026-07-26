library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity mult8_tb is
    generic (runner_cfg: string);
end;

architecture tb of mult8_tb is
    constant CLK_PERIOD: time := 10 ns;

    signal clk: std_logic := '1';
    signal a, b: std_logic_vector(7 downto 0);
    signal y1, y2: std_logic_vector(15 downto 0);
begin
    clk <= not clk after CLK_PERIOD / 2;

UUT1:
    entity work.mult8(combi_1)
        port map (
            a => a,
            b => b,
            y => y1
        );

UUT2:
    entity work.mult8(combi_2)
        port map (
            a => a,
            b => b,
            y => y2
        );

    process
    begin
        test_runner_setup(runner, runner_cfg);

        wait for 1 * CLK_PERIOD;
        a <= x"00";
        b <= x"00";

        wait for 1 * CLK_PERIOD;
        a <= x"01";

        wait for 1 * CLK_PERIOD;
        b <= x"01";

        wait for 1 * CLK_PERIOD;
        a <= x"ff";
        b <= x"ff";

        wait for 1 * CLK_PERIOD;

        test_runner_cleanup(runner);
    end process;
end;
