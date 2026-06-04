library ieee;
    use ieee.std_logic_1164.all, ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity century_counter_tb is
    generic (runner_cfg: string);
end;

architecture tb of century_counter_tb is
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';
    signal tens_en, carry: std_logic;
    signal count: unsigned(7 downto 0);
begin
    clk <= not clk after 1 ns;

UUT0:
    entity work.decade_counter(rtl)
        port map (
            clk => clk,
            rst => rst,
            eno => '1',
            enp => '1',
            ent => '1',
            rco => tens_en,
            count => count(3 downto 0)
        );

UUT1:
    entity work.decade_counter(rtl)
        port map (
            clk => clk,
            rst => rst,
            eno => '1',
            enp => '1',
            ent => tens_en,
            rco => carry,
            count => count(7 downto 4)
        );

    process
    begin
        test_runner_setup(runner, runner_cfg);

        wait for 5 ns;

        check_equal(carry, '0');
        check_equal(count, 0);

        rst <= '0';

        for t in 0 to 9 loop
            for o in 0 to 9 loop
                wait until falling_edge(clk);
                check_equal(count(7 downto 4), t);
                check_equal(count(3 downto 0), o);
            end loop;
        end loop;

        wait until falling_edge(clk);
        check_equal(count, 0);

        wait for 5 ns;

        test_runner_cleanup(runner);
    end process;
end;
