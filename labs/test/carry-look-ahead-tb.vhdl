library ieee;
    use ieee.std_logic_1164.all, ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity carry_look_ahead_tb is
    generic (runner_cfg: string);
end;

architecture tb of carry_look_ahead_tb is
    constant CLK_PERIOD: time := 10 ns;

    signal clk, rst, enp: std_logic := '1';

    type counts_t is array (3 downto 0) of unsigned(3 downto 0);
    signal counts: counts_t;
    signal rcos: std_logic_vector(3 downto 0);
begin
    clk <= not clk after CLK_PERIOD / 2;

DC0:
    entity work.decade_counter(rtl)
        port map (
            clk => clk,
            rst => rst,
            eno => '1',
            enp => enp,
            ent => '1',
            rco => rcos(0),
            count => counts(0)
        );

DC1:
    entity work.decade_counter(rtl)
        port map (
            clk => clk,
            rst => rst,
            eno => '1',
            enp => rcos(0),
            ent => enp,
            rco => rcos(1),
            count => counts(1)
        );

DC2:
    entity work.decade_counter(rtl)
        port map (
            clk => clk,
            rst => rst,
            eno => '1',
            enp => rcos(0),
            ent => rcos(1),
            rco => rcos(2),
            count => counts(2)
        );

DC3:
    entity work.decade_counter(rtl)
        port map (
            clk => clk,
            rst => rst,
            eno => '1',
            enp => rcos(0),
            ent => rcos(2),
            rco => rcos(3),
            count => counts(3)
        );

    process
    begin
        test_runner_setup(runner, runner_cfg);

        wait for 3 * CLK_PERIOD;
        rst <= '0';

        for th in 0 to 9 loop
            for h in 0 to 9 loop
                for te in 0 to 9 loop
                    for o in 0 to 9 loop
                        wait until falling_edge(clk);
                        check_equal(counts(0), o);
                        check_equal(counts(1), te);
                        check_equal(counts(2), h);
                        check_equal(counts(3), th);
                    end loop;
                end loop;
            end loop;
        end loop;

        wait for 5 * CLK_PERIOD;

        test_runner_cleanup(runner);
    end process;
end;
