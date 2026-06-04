library ieee;
    use ieee.std_logic_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity lab_03_tb is
    generic (runner_cfg: string);
end;

architecture tb of lab_03_tb is
    constant CLK_PERIOD: time := 10 ns;

    signal clk, reset_n: std_logic := '0';
    signal switches, leds: std_logic_vector(15 downto 0);
    signal ssd_abcdefg: std_logic_vector(6 downto 0);
    signal ssd_dp: std_logic;
    signal ssd_en: std_logic_vector(7 downto 0);
begin
    clk <= not clk after CLK_PERIOD / 2;
    reset_n <= '1' after 3 * CLK_PERIOD;

dut:
    entity work.lab_03
        generic map (
            CYCLES_PER_SECOND => 1,
            CYCLES_PER_SSD => 1
        )
        port map (
            clk => clk,
            reset_n => reset_n,
            switches => switches,
            leds => leds,
            ssd_abcdefg => ssd_abcdefg,
            ssd_dp => ssd_dp,
            ssd_en => ssd_en
        );

    process
    begin
        test_runner_setup(runner, runner_cfg);

        switches <= (others => '0');

        wait for 120 * CLK_PERIOD;

        test_runner_cleanup(runner);
    end process;
end;
