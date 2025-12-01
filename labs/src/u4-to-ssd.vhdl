library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity u4_to_ssd is
    port (
        u4: in unsigned(3 downto 0);
        abcdefg: out std_logic_vector(6 downto 0)
    );
end;

architecture rtl of u4_to_ssd is
begin
    with u4 select
        abcdefg <=
            "0000001" when x"0",
            "1001111" when x"1",
            "0010010" when x"2",
            "0000110" when x"3",
            "1001100" when x"4",
            "0100100" when x"5",
            "0100000" when x"6",
            "0001111" when x"7",
            "0000000" when x"8",
            "0000100" when x"9",
            "0001000" when x"a",
            "1100000" when x"b",
            "0110001" when x"c",
            "1000010" when x"d",
            "0110000" when x"e",
            "0111000" when x"f",
            "1111111" when others;
end;
