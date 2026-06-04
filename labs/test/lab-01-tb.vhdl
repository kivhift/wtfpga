library ieee;
    use ieee.std_logic_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity lab_01_tb is
    generic (runner_cfg: string);
end;

architecture tb of lab_01_tb is
    constant W: time := 7 ns;
    signal clk: std_logic := '0';
    signal reset: std_logic := '1';
    signal btn_n, btn_s, btn_e, btn_w: std_logic := '0';
    signal sw: std_logic_vector(15 downto 0) := 16x"0000";

    signal leds: std_logic_vector(15 downto 0);
    signal ssd_abcdefg: std_logic_vector(6 downto 0);
    signal ssd_dp: std_logic;
    signal ssd_digit_en: std_logic_vector(7 downto 0);
    signal rgb_leds: std_logic_vector(5 downto 0);
begin
    clk <= not clk after 1 ns;

DUT:
    entity work.lab_01
        generic map (
            BLINK_EVERY => 6,
            PWM_PERIOD => 4,
            PWM_DUTY => 1
        )
        port map (
            clk => clk,
            reset_n => not reset,
            btn_c => '0',
            btn_n => btn_n,
            btn_s => btn_s,
            btn_e => btn_e,
            btn_w => btn_w,
            sw => sw,
            leds => leds,
            ssd_abcdefg => ssd_abcdefg,
            ssd_dp => ssd_dp,
            ssd_digit_en => ssd_digit_en,
            rgb_leds => rgb_leds
        );

    process
    begin
        test_runner_setup(runner, runner_cfg);

        wait for 5 ns;
        reset <= '0';

        wait for W;
        btn_n <= '1';
        sw <= 16x"a5c3";

        wait for W;
        btn_n <= '0';
        btn_w <= '1';

        wait for W;
        btn_w <= '0';
        btn_e <= '1';

        wait for W;
        btn_e <= '0';
        btn_s <= '1';

        wait for W;
        btn_s <= '0';

        wait for 50 ns;

        test_runner_cleanup(runner);
    end process;
end;
