-- Listing 9.7
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity gray_counter4 is
    port (
        clk, rst: in std_logic;
        q: out std_logic_vector(3 downto 0)
    );
end;

architecture orig of gray_counter4 is
    signal reg_d, reg_q, b, b1: unsigned(q'range);
begin
    -- register
    process (clk, rst)
    begin
        if rst then
            reg_q <= (others => '0');
        elsif rising_edge(clk) then
            reg_q <= reg_d;
        end if;
    end process;

    -- Gray to binary
    b <= reg_q xor ('0' & b(q'left downto 1));
    b1 <= b + 1;

    -- binary to Gray
    reg_d <= b1 xor ('0' & b1(q'left downto 1));

    -- output logic
    q <= std_logic_vector(reg_q);
end;

architecture rtl of gray_counter4 is
    signal reg_d, reg_q: unsigned(q'range);
begin
    -- register
    process (clk, rst)
    begin
        if rst then
            reg_q <= (others => '0');
        elsif rising_edge(clk) then
            reg_q <= reg_d;
        end if;
    end process;

    -- next-state logic
    reg_d <= reg_q + 1;

    -- output logic
    q <= std_logic_vector(reg_q xor ('0' & reg_q(q'left downto 1)));
end;
