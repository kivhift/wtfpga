library ieee;
    use ieee.std_logic_1164.all, ieee.numeric_std.all;

entity decade_counter is
    port (
        clk, rst, eno, enp, ent: in std_logic;
        rco: out std_logic;
        count: out unsigned(3 downto 0)
    );
end;

architecture rtl of decade_counter is
    constant ZERO: unsigned(count'range) := (others => '0');

    signal carry: std_logic;
    signal value: unsigned(count'range);
begin
    carry <= value(3) and value(0);
    rco <= ent and carry;
    count <= eno and value;

    process (clk, rst)
    begin
        if rst then
            value <= ZERO;
        elsif rising_edge(clk) then
            if enp and ent then
                value <= ZERO when carry else value + 1;
            end if;
        end if;
    end process;
end;
