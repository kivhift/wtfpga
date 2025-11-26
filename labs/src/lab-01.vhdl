library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity lab_01 is
    generic (
        BLINK_EVERY: positive := 16#2fa_f07f#
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
    constant DELAY_LIMIT: unsigned(25 downto 0) := to_unsigned(BLINK_EVERY, 26);
    signal delay: unsigned(DELAY_LIMIT'range);
    signal blink: std_logic;
begin

p_blink:
    process (clk, reset)
    begin
        if reset then
            blink <= '0';
            delay <= to_unsigned(0, delay'length);
        elsif rising_edge(clk) then
            delay <= delay + 1;
            if DELAY_LIMIT = delay then
                blink <= not blink;
                delay <= to_unsigned(0, delay'length);
            end if;
        end if;
    end process;

    led <=
        16x"ffff" when btn_n else
        16x"5555" when btn_w else
        16x"aaaa" when btn_e else
        (sw and blink);

    ssd_abcdefg <= (others => '0');
    ssd_dp <= '0';
    ssd_digit_en <= (others => not (btn_s or blink));

    led_r0 <= blink;
    led_g0 <= blink;
    led_b0 <= blink;
    led_r1 <= blink;
    led_g1 <= blink;
    led_b1 <= blink;
end;
