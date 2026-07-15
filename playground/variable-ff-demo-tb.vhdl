library ieee;
    use ieee.std_logic_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity variable_ff_demo_tb is
    generic (runner_cfg: string);
end;

architecture tb of variable_ff_demo_tb is
    signal clk: std_logic := '1';
    signal a, b, q1, q2, q3: std_logic;
begin
    clk <= not clk after 1 ns;

UUT:
    entity work.variable_ff_demo
        port map (
            clk => clk,
            a => a,
            b => b,
            q1 => q1,
            q2 => q2,
            q3 => q3
        );

    process
    begin
        test_runner_setup(runner, runner_cfg);

        wait for 1 ns;
        a <= '0';
        b <= '0';

        wait for 6 ns;
        a <= '1';

        wait for 6 ns;
        b <= '1';

        wait for 6 ns;
        a <= '0';

        wait for 6 ns;

        test_runner_cleanup(runner);
    end process;
end;
