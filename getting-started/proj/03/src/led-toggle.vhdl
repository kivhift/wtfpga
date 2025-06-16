library ieee;
    use ieee.std_logic_1164.all;

entity led_toggle is
    port(
        clk, sw: in std_logic
        ; led: out std_logic
    );
end;

-- At the clock rising edge, toggle led if sw has fallen.
architecture rtl of led_toggle is
    signal led_reg: std_logic := '0';
    signal sw_reg: std_logic := '0';
begin
    led <= led_reg;

    process(clk) is
    begin
        if rising_edge(clk) then
            sw_reg <= sw;
            if '0' = sw and '1' = sw_reg then
                led_reg <= not led_reg;
            end if;
        end if;
    end process;
end;
