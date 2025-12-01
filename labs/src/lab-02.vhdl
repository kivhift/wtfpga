library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity lab_02 is
    port (
        clk, rst: in std_logic;

        leds: out std_logic_vector(15 downto 0);
        ssd_abcdefg: out std_logic_vector(6 downto 0);
        ssd_dp: out std_logic;
        ssd_digit_en: out std_logic_vector(7 downto 0);
        led_r0, led_g0, led_b0, led_r1, led_g1, led_b1: out std_logic
    );
end;

architecture bhv of lab_02 is
begin
    -- The RGB LEDs aren't used but we set them to off regardless.
    led_r0 <= '0';
    led_g0 <= '0';
    led_b0 <= '0';
    led_r1 <= '0';
    led_g1 <= '0';
    led_b1 <= '0';

    -- These are set to off for now...
    ssd_abcdefg <= b"111_1111";
    ssd_dp <= '1';
    ssd_digit_en <= b"1111_1111";

larson_scanner:
    process (clk, rst)
        constant ALL_ZEROS: bit_vector(leds'range) := (others => '0');
        constant RESET_STATE: bit_vector(leds'range) := (
            leds'left => '1', others => '0'
        );

        variable state: bit_vector(leds'range);
        variable shift_right: boolean;
        -- Upon rollover, shift to the next LED. With 22 bits and 100MHz clock
        -- frequency, each LED is lit for about 42ms.
        variable dwell_count: unsigned(21 downto 0);
    begin
        if rst then
            state := RESET_STATE;
            shift_right := true;
            dwell_count := (others => '0');
        elsif rising_edge(clk) then
            dwell_count := dwell_count + 1;

            if 0 = dwell_count then
                if shift_right then
                    state := '0' & state(state'left downto 1);
                else
                    state := state(state'left - 1 downto 0) & '0';
                end if;

                if state(state'left) then
                    -- In case there are multiple bits set, self correct here.
                    state := RESET_STATE;
                    shift_right := true;
                elsif state(state'right) then
                    shift_right := false;
                end if;

                -- Self correct in case we're in a bad state.
                if ALL_ZEROS = state then
                    state := RESET_STATE;
                    shift_right := true;
                end if;
            end if;
        end if;

        leds <= to_slv(state);
    end process;
end;
