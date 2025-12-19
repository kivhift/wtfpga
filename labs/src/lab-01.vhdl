library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity lab_01 is
    generic (
        BLINK_EVERY: positive := 50000000;
        -- PWM with 10% duty at 1kHz.
        PWM_PERIOD: positive := 100000;
        PWM_DUTY: natural := 10000
    );
    port (
        clk: in std_logic;
        reset: in std_logic;
        btn_n, btn_s, btn_e, btn_w: in std_logic;
        sw: in std_logic_vector(15 downto 0);

        led: out std_logic_vector(15 downto 0);
        ssd_abcdefg: out std_logic_vector(6 downto 0);
        ssd_dp: out std_logic;
        ssd_digit_en: out std_logic_vector(7 downto 0);
        led_r0, led_g0, led_b0, led_r1, led_g1, led_b1: out std_logic
    );
end;

architecture bhv of lab_01 is
    signal blink, rgb_blink, rgb_pwm: std_logic;
begin

blink_pwm:
    entity work.pulse_width_modulation(rtl)
        generic map (
            PERIOD => BLINK_EVERY * 2,
            DUTY => BLINK_EVERY
        )
        port map (
            clk => clk,
            rst => reset,
            en => '1',
            output => blink
        );

brightness_pwm:
    entity work.pulse_width_modulation(rtl)
        generic map (
            PERIOD => PWM_PERIOD,
            DUTY => PWM_DUTY
        )
        port map (
            clk => clk,
            rst => reset,
            en => '1',
            output => rgb_pwm
        );

    led <=
        16x"ffff" when btn_n else
        16x"5555" when btn_w else
        16x"aaaa" when btn_e else
        (sw and blink);

    ssd_abcdefg <= (others => '0');
    ssd_dp <= '0';
    ssd_digit_en <= (others => not (btn_s or blink));

    rgb_blink <= blink and rgb_pwm;
    led_r0 <= rgb_blink;
    led_g0 <= rgb_blink;
    led_b0 <= rgb_blink;
    led_r1 <= rgb_blink;
    led_g1 <= rgb_blink;
    led_b1 <= rgb_blink;
end;
