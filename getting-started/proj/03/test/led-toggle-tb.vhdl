library ieee;
    use ieee.std_logic_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity led_toggle_tb is
    generic(runner_cfg: string);
end;

architecture tb of led_toggle_tb is
    constant HALF_PERIOD: time := 1 ns;

    signal clk: std_logic := '0';
    signal sw: std_logic := '0';
    signal led: std_logic := '0';
begin
    clk <= not clk after HALF_PERIOD;

DUT:
    entity work.led_toggle port map(
        clk => clk
        , sw => sw
        , led => led
    );

    process
    begin
        test_runner_setup(runner, runner_cfg);

        wait until falling_edge(clk);
        sw <= '0';

        wait until falling_edge(clk);
        check_equal(led, '0');
        sw <= '1';

        wait until falling_edge(clk);
        check_equal(led, '0');
        sw <= '0';

        wait until falling_edge(clk);
        check_equal(led, '1');

        wait until falling_edge(clk);
        check_equal(led, '1');
        sw <= '1';

        wait until falling_edge(clk);
        check_equal(led, '1');
        sw <= '0';

        wait until falling_edge(clk);
        check_equal(led, '0');

        wait until falling_edge(clk);

        test_runner_cleanup(runner);
    end process;
end;
