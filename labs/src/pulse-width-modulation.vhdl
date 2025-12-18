library ieee;
    use ieee.std_logic_1164.all, ieee.numeric_std.all;

use work.utils.all;

entity pulse_width_modulation is
    generic (
        PERIOD: positive;
        DUTY: natural
    );
    port (
        clk, rst, en: in std_logic;
        output: out std_logic
    );
end;

architecture rtl of pulse_width_modulation is
    signal pwm: std_logic;
begin
    assert PERIOD >= DUTY
        report "DUTY should not be more than PERIOD: "
            & to_string(DUTY) & " > " & to_string(PERIOD)
        severity failure;

    output <= pwm when en else '0';

pwm_generate:
    if 0 = DUTY generate
        pwm <= '0';
    elsif PERIOD = DUTY generate
        pwm <= '1';
    else generate
        constant limit: positive := PERIOD - 1;
        signal count: unsigned (bit_width(PERIOD) - 1 downto 0);
    begin
        pwm <= '1' when count < DUTY else '0';

        process (clk, rst)
        begin
            if rst then
                count <= (others => '0');
            elsif rising_edge(clk) then
                if limit = count then
                    count <= (others => '0');
                else
                    count <= count + 1;
                end if;
            end if;
        end process;
    end generate;
end;
