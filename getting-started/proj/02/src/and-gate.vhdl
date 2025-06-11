library ieee;
    use ieee.std_logic_1164.all;

entity and_gate is
    port(
        sw0, sw1: in std_logic
        ; led0: out std_logic
    );
end;

architecture rtl of and_gate is
begin
    led0 <= sw0 and sw1;
end;
