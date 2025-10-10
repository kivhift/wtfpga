library ieee;
    use ieee.std_logic_1164.all;
    use ieee.math_real.uniform;

library vunit_lib;
context vunit_lib.vunit_context;

entity debounce_filter_tb is
    generic(runner_cfg: string);
end;

architecture tb of debounce_filter_tb is
    constant HALF_PERIOD: time := 1 ns;
    constant DEBOUNCE_LIMIT: positive := 10;

    signal clk: std_logic := '0';
    signal input, output: std_logic;
begin
    clk <= not clk after HALF_PERIOD;

DUT:
    entity work.debounce_filter
        generic map(DEBOUNCE_LIMIT => DEBOUNCE_LIMIT)
        port map(clk => clk, bouncy => input, debounced => output);

    process
        variable s0, s1: positive := 128;
        variable rand_bits: std_logic_vector(0 to 4 * DEBOUNCE_LIMIT);

        -- Adapted from: https://vhdlwhiz.com/random-numbers/
        impure function rand_slv(len: positive) return std_logic_vector is
            variable r: real;
            variable slv: std_logic_vector(0 to len - 1);
        begin
            for i in slv'range loop
                uniform(s0, s1, r);
                slv(i) := '1' when r > 0.5 else '0';
            end loop;

            return slv;
        end;
    begin
        test_runner_setup(runner, runner_cfg);

        -- Fake the bouncy bouncy...
        rand_bits := rand_slv(rand_bits'length);
        for i in rand_bits'range loop
            wait until falling_edge(clk);
            input <= rand_bits(i);
        end loop;

        -- ... then wait for enough clock cycles before checking.
        for i in 0 to DEBOUNCE_LIMIT loop
            wait until rising_edge(clk);
        end loop;

        wait until falling_edge(clk);

        check_equal(output, input);

        test_runner_cleanup(runner);
    end process;
end;
