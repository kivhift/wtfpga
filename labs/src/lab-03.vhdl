library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity lab_03 is
    generic (
        CYCLES_PER_SECOND: positive := 100_000_000;
        CYCLES_PER_SSD: positive := 2_000_000
    );
    port (
        clk, reset_n: in std_logic;
        switches: in std_logic_vector(15 downto 0);

        leds: out std_logic_vector(15 downto 0);
        ssd_abcdefg: out std_logic_vector(6 downto 0);
        ssd_dp: out std_logic;
        ssd_en: out std_logic_vector(7 downto 0)
    );
end;

architecture bhv of lab_03 is
    subtype u4_type is unsigned(3 downto 0);
    constant U4_ZERO: u4_type := "0000";

    type bcd_type is record
        tens, ones: u4_type;
    end record;
    constant BCD_ZERO: bcd_type := (U4_ZERO, U4_ZERO);

    procedure incr_bcd(signal x: inout bcd_type) is
    begin
        if x.ones = 9 then
            x.ones <= U4_ZERO;
            x.tens <= x.tens + 1;
        else
            x.ones <= x.ones + 1;
        end if;
    end;

    -- This is HMS, the easier-to-display/set version.
    type clock_time_type is record
        hours, minutes, seconds: bcd_type;
    end record;
    signal wall_clock: clock_time_type;

    type digits_type is array (ssd_en'range) of u4_type;
    signal digits: digits_type;
    signal ssd_enable: bit_vector(ssd_en'range);
    signal u4: u4_type;

    signal one_second_passed: bit;
    signal one_second_cycle_count, ssd_dwell_count: natural;

    type segment_array is array (7 downto 0) of bit_vector(6 downto 0);
    signal ssds: segment_array;
begin
    leds <= switches;
    ssd_dp <= '1';
    ssd_en <= to_slv(not ssd_enable);
    with ssd_enable select
        u4 <=
            digits(0) when "00000001",
            digits(1) when "00000010",
            digits(2) when "00000100",
            digits(3) when "00001000",
            digits(4) when "00010000",
            digits(5) when "00100000",
            digits(6) when "01000000",
            digits(7) when others;

    -- For now, hardcoded
    digits(7) <= "0000";
    digits(6) <= "0000";
    digits(5) <= wall_clock.hours.tens;
    digits(4) <= wall_clock.hours.ones;
    digits(3) <= wall_clock.minutes.tens;
    digits(2) <= wall_clock.minutes.ones;
    digits(1) <= wall_clock.seconds.tens;
    digits(0) <= wall_clock.seconds.ones;

u4_to_ssd:
    entity work.u4_to_ssd
        port map (
            u4 => u4,
            abcdefg => ssd_abcdefg
        );

tick:
    process (clk)
        constant CYCLE_COUNT_LIMIT: natural := CYCLES_PER_SECOND - 1;
    begin
        if rising_edge(clk) then
            one_second_passed <= '0';
            one_second_cycle_count <= one_second_cycle_count + 1;

            if reset_n = '0' then
                one_second_cycle_count <= 0;
            elsif one_second_cycle_count = CYCLE_COUNT_LIMIT then
                one_second_passed <= '1';
                one_second_cycle_count <= 0;
            end if;
        end if;
    end process;

update_time:
    process (clk)
        constant HOURS_MAX: bcd_type := ("0010", "0011");
        constant MINSEC_MAX: bcd_type := ("0101", "1001");
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                wall_clock <= (others => BCD_ZERO);
            elsif one_second_passed then
                if wall_clock.seconds = MINSEC_MAX then
                    wall_clock.seconds <= BCD_ZERO;
                    if wall_clock.minutes = MINSEC_MAX then
                        wall_clock.minutes <= BCD_ZERO;
                        if wall_clock.hours = HOURS_MAX then
                            wall_clock.hours <= BCD_ZERO;
                        else
                            incr_bcd(wall_clock.hours);
                        end if;
                    else
                        incr_bcd(wall_clock.minutes);
                    end if;
                else
                    incr_bcd(wall_clock.seconds);
                end if;
            end if;
        end if;
    end process;

mux_ssds:
    process (clk)
        constant DWELL_LIMIT: natural := CYCLES_PER_SSD - 1;
    begin
        if rising_edge(clk) then
            ssd_dwell_count <= ssd_dwell_count + 1;

            if reset_n = '0' then
                ssd_dwell_count <= 0;
                ssd_enable <= (0 => '1', others => '0');
            elsif ssd_dwell_count = DWELL_LIMIT then
                ssd_dwell_count <= 0;
                ssd_enable <=
                    ssd_enable(0) & ssd_enable(ssd_enable'left downto 1);
            end if;
        end if;
    end process;
end;
