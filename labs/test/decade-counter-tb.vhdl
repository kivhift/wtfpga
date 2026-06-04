library ieee;
    use ieee.std_logic_1164.all, ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity decade_counter_tb is
    generic (runner_cfg: string);
end;

architecture tb of decade_counter_tb is
    signal clk: std_logic := '0';
    signal eno, enp, ent, rst: std_logic := '1';
    signal carry: std_logic;
    signal count: unsigned(3 downto 0);
begin
    clk <= not clk after 1 ns;

UUT:
    entity work.decade_counter
        port map (
            clk => clk,
            rst => rst,
            eno => eno,
            enp => enp,
            ent => ent,
            rco => carry,
            count => count
        );

    process
    begin
        test_runner_setup(runner, runner_cfg);

        wait for 5 ns;

        -- We're in reset so outputs should be low.
        check_equal(carry, '0');
        check_equal(count, 0);

        rst <= '0';

        -- Check that it counts correctly.
        wait until rising_edge(clk);
        for i in 1 to 8 loop
            wait until falling_edge(clk);
            check_equal(carry, '0');
            check_equal(count, i);
        end loop;

        -- Check that RCO is set when the count is 9.
        wait until falling_edge(clk);
        check_equal(carry, '1');
        check_equal(count, 9);

        -- Check that rollover happens.
        wait until falling_edge(clk);
        check_equal(carry, '0');
        check_equal(count, 0);

        -- Increment once, then disable ENP, wait and check that no increment
        -- occurred.
        wait until falling_edge(clk);
        enp <= '0';
        wait for 10 ns;
        check_equal(carry, '0');
        check_equal(count, 1);

        -- Enable ENP and verify that increments continue.
        enp <= '1';
        wait until rising_edge(clk);
        for i in 2 to 8 loop
            wait until falling_edge(clk);
            check_equal(carry, '0');
            check_equal(count, i);
        end loop;

        -- Pause the count while RCO is high.
        wait until falling_edge(clk);
        enp <= '0';

        -- Wait a bit and then check that nothing has changed.
        wait for 10 ns;
        check_equal(carry, '1');
        check_equal(count, 9);

        -- Disabling ENT should also make RCO go low.
        ent <= '0';
        wait for 10 ns;
        check_equal(carry, '0');
        check_equal(count, 9);

        -- Enabling ENP while ENT is low does not make the count continue, nor
        -- does it make RCO go high again.
        enp <= '1';
        wait for 10 ns;
        check_equal(carry, '0');
        check_equal(count, 9);

        -- With the count still paused, enabling ENT should make RCO go back to
        -- high.
        enp <= '0';
        ent <= '1';
        wait for 10 ns;
        check_equal(carry, '1');
        check_equal(count, 9);

        -- With both ENP and ENT enabled, the count should continue.
        enp <= '1';
        wait until rising_edge(clk);
        for i in 0 to 8 loop
            wait until falling_edge(clk);
            check_equal(carry, '0');
            check_equal(count, i);
        end loop;

        wait until falling_edge(clk);
        check_equal(carry, '1');
        check_equal(count, 9);

        -- With the output disabled, it should count normally but only output
        -- zeros.
        eno <= '0';
        wait until rising_edge(clk);
        for i in 0 to 8 loop
            wait until falling_edge(clk);
            check_equal(carry, '0');
            check_equal(count, 0);
        end loop;

        wait until falling_edge(clk);
        check_equal(carry, '1');
        check_equal(count, 0);

        for i in 0 to 7 loop
            wait until rising_edge(clk);
        end loop;

        -- Enabling the output should result in the correct count reappearing.
        eno <= '1';
        wait until falling_edge(clk);
        check_equal(carry, '0');
        check_equal(count, 7);
        wait until falling_edge(clk);
        check_equal(carry, '0');
        check_equal(count, 8);
        wait until falling_edge(clk);
        check_equal(carry, '1');
        check_equal(count, 9);

        wait for 10 ns;

        test_runner_cleanup(runner);
    end process;
end;
