-- Simple project to demonstrate the basics of VHDL.

library ieee;
    use ieee.std_logic_1164.all;

entity switches_to_leds is
    port(
        sw0, sw1, sw2, sw3: in std_logic
        ; led0, led1, led2, led3: out std_logic
    );
end;

architecture rtl of switches_to_leds is
begin
    led0 <= sw0;
    led1 <= sw1;
    led2 <= sw2;
    led3 <= sw3;
end;
