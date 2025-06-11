library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity and_gate_tb is
    generic(runner_cfg: string);
end;

architecture tb of and_gate_tb is
    signal input: std_logic_vector(0 to 1);
    signal output: std_logic;
begin

DUT:
    entity work.and_gate port map(
        sw0 => input(0)
        , sw1 => input(1)
        , led0 => output
    );

    process
    begin
        test_runner_setup(runner, runner_cfg);

        for i in 0 to (2 ** input'length) - 1 loop
            input <= std_logic_vector(to_unsigned(natural(i), input'length));
            wait for ns;
            if 3 = i then
                check_equal(output, '1');
            else
                check_equal(output, '0');
            end if;
        end loop;

        test_runner_cleanup(runner);
    end process;
end;
