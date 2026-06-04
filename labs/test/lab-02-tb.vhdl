library ieee;
    use ieee.std_logic_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity lab_02_tb is
    generic (runner_cfg: string);
end;

architecture tb of lab_02_tb is
    constant CLK_PERIOD: time := 10 ns;

    signal clk: std_logic := '0';
    signal rst: std_logic := '1';

    signal leds: std_logic_vector(15 downto 0);
    signal ssd_abcdefg: std_logic_vector(6 downto 0);
    signal ssd_dp: std_logic;
    signal ssd_digit_en: std_logic_vector(7 downto 0);
    signal rgb_leds: std_logic_vector(5 downto 0);
begin
    clk <= not clk after CLK_PERIOD / 2;

DUT:
    entity work.lab_02
        generic map (
            INC_DELAY_WIDTH => 1,
            DIGIT_MUX_DWELL_WIDTH => 1,
            LARSON_DWELL_WIDTH => 1
        )
        port map (
            clk => clk,
            rst => rst,
            leds => leds,
            ssd_abcdefg => ssd_abcdefg,
            ssd_dp => ssd_dp,
            ssd_digit_en => ssd_digit_en,
            led_r0 => rgb_leds(5),
            led_g0 => rgb_leds(4),
            led_b0 => rgb_leds(3),
            led_r1 => rgb_leds(2),
            led_g1 => rgb_leds(1),
            led_b1 => rgb_leds(0)
        );

    process
    begin
        test_runner_setup(runner, runner_cfg);

        wait for 4 * CLK_PERIOD;
        rst <= '0';

        wait for 100 * CLK_PERIOD;

        test_runner_cleanup(runner);
    end process;
end;
