library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity switches_to_leds_tb is
    generic(runner_cfg: string);
end;

architecture tb of switches_to_leds_tb is
    signal input, output: std_logic_vector(0 to 3);
begin

DUT:
    entity work.switches_to_leds port map(
        sw0 => input(0)
        , sw1 => input(1)
        , sw2 => input(2)
        , sw3 => input(3)
        , led0 => output(0)
        , led1 => output(1)
        , led2 => output(2)
        , led3 => output(3)
    );

    process
    begin
        test_runner_setup(runner, runner_cfg);

        for i in 0 to (2 ** input'length) - 1 loop
            input <= std_logic_vector(to_unsigned(natural(i), input'length));
            wait for ns;
            check_equal(output, input);
        end loop;

        test_runner_cleanup(runner);
    end process;
end;
