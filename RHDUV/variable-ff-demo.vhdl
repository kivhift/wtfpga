-- Listing 8.24
library ieee;
    use ieee.std_logic_1164.all;

entity variable_ff_demo is
    port (
        clk, a, b: in std_logic;
        q1, q2, q3: out std_logic
    );
end;

architecture arch of variable_ff_demo is
    signal tmp_sig1: std_logic;
begin
    -- attempt 1
    process (clk)
    begin
        if rising_edge(clk) then
            tmp_sig1 <= a and b;
            q1 <= tmp_sig1;
        end if;
    end process;

    -- attempt 2
    process (clk)
        variable tmp_var2: std_logic;
    begin
        if rising_edge(clk) then
            tmp_var2 := a and b;
            q2 <= tmp_var2;
        end if;
    end process;

    -- attempt 3
    process (clk)
        variable tmp_var3: std_logic;
    begin
        if rising_edge(clk) then
            q3 <= tmp_var3;
            tmp_var3 := a and b;
        end if;
    end process;
end;
