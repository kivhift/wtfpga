library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity lab_02 is
    -- Various delays are based on the rollover of an unsigned at a given
    -- width. Put these here to make simulation easier.
    generic (
        INC_DELAY_WIDTH: positive := 25;
        DIGIT_MUX_DWELL_WIDTH: positive := 18;
        LARSON_DWELL_WIDTH: positive := 22
    );
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
    signal u4: unsigned(3 downto 0);
    signal digit_enable: std_logic_vector(ssd_digit_en'range);
    signal count_enable: std_logic;

    type digit_count_t is array (digit_enable'range) of unsigned(u4'range);
    signal counts: digit_count_t;
    signal rcos: std_logic_vector(counts'high - 1 downto 0);
begin
    -- These aren't used so set them to off.
    led_r0 <= '0';
    led_g0 <= '0';
    led_b0 <= '0';
    led_r1 <= '0';
    led_g1 <= '0';
    led_b1 <= '0';
    ssd_dp <= '1';

    ssd_digit_en <= digit_enable;
    u4 <= ((counts(7) or counts(6)) or (counts(5) or counts(4)))
        or ((counts(3) or counts(2)) or (counts(1) or counts(0)));

u4_to_ssd:
    entity work.u4_to_ssd
        port map (
            u4 => u4,
            abcdefg => ssd_abcdefg
        );

dc_MSD:
    entity work.decade_counter
        port map (
            clk => clk,
            rst => rst,
            eno => not digit_enable(counts'high),
            enp => '1',
            ent => rcos(counts'high - 1),
            rco => open,
            count => counts(counts'high)
        );

dc_middle_gen:
    for i in counts'high - 1 downto counts'low + 1 generate
    dc_i:
        entity work.decade_counter
            port map (
                clk => clk,
                rst => rst,
                eno => not digit_enable(i),
                enp => '1',
                ent => rcos(i - 1),
                rco => rcos(i),
                count => counts(i)
            );
    end generate;

dc_LSD:
    entity work.decade_counter
        port map (
            clk => clk,
            rst => rst,
            eno => not digit_enable(counts'low),
            enp => '1',
            ent => count_enable,
            rco => rcos(counts'low),
            count => counts(counts'low)
        );

increment_count:
    process (clk, rst)
        variable delay_count: unsigned(INC_DELAY_WIDTH - 1 downto 0);
    begin
        if rst then
            delay_count := (others => '0');
        elsif rising_edge(clk) then
            delay_count := delay_count + 1;
        end if;

        count_enable <= '1' when 0 = delay_count else '0';
    end process;

mux_digits:
    process (clk, rst)
        constant ONES: bit_vector(digit_enable'left downto 1) := (others => '1');

        variable state: bit_vector(digit_enable'range);
        variable shift_in: bit;
        variable dwell_count: unsigned(DIGIT_MUX_DWELL_WIDTH - 1 downto 0);
    begin
        if rst then
            state := (others => '1');
            dwell_count := (others => '0');
        elsif rising_edge(clk) then
            dwell_count := dwell_count + 1;

            if 0 = dwell_count then
                shift_in := '0' when state(state'left downto 1) = ONES else '1';
                state := shift_in & state(state'left downto 1);
            end if;
        end if;

        digit_enable <= to_slv(state);
    end process;

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
        variable dwell_count: unsigned(LARSON_DWELL_WIDTH - 1 downto 0);
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
