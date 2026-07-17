library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity gray_counter4_tb is
    generic (runner_cfg: string);
end;

architecture tb of gray_counter4_tb is
    type gray4_array_type is array (natural range 0 to 15)
        of std_logic_vector(3 downto 0);
    constant gray4_codes: gray4_array_type := (
        0 => x"0", 1 => x"1", 2 => x"3", 3 => x"2",
        4 => x"6", 5 => x"7", 6 => x"5", 7 => x"4",
        8 => x"c", 9 => x"d", 10 => x"f", 11 => x"e",
        12 => x"a", 13 => x"b", 14 => x"9", 15 => x"8"
    );
    constant CLK_PERIOD: time := 10 ns;

    signal clk, rst: std_logic := '1';
    signal q: std_logic_vector(3 downto 0);
begin
    clk <= not clk after CLK_PERIOD / 2;

UUT:
    entity work.gray_counter4(rtl)
        port map (
            clk => clk,
            rst => rst,
            q => q
        );

    process
    begin
        test_runner_setup(runner, runner_cfg);

        wait for 3 * CLK_PERIOD;
        rst <= '0';

        for i in gray4_codes'range loop
            wait until falling_edge(clk);
            check_equal(q, gray4_codes(i));
        end loop;

        wait for 50 * CLK_PERIOD;

        test_runner_cleanup(runner);
    end process;
end;
