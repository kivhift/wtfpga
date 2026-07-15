library ieee;
    use ieee.std_logic_1164.all, ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity binary_counter4_pulse_tb is
    generic (runner_cfg: string);
end;

architecture tb of binary_counter4_pulse_tb is
    signal clk, reset: std_logic := '1';
    signal mp0, mp1, mp2: std_logic;
    signal q0, q1, q2: std_logic_vector(3 downto 0);
begin
    clk <= not clk after 1 ns;
    reset <= '0' after 4 ns;

UUT0:
    entity work.binary_counter4_pulse(two_seg_arch)
        port map (
            clk => clk,
            reset => reset,
            max_pulse => mp0,
            q => q0
        );

UUT1:
    entity work.binary_counter4_pulse(broken_one_seg_arch)
        port map (
            clk => clk,
            reset => reset,
            max_pulse => mp1,
            q => q1
        );

UUT2:
    entity work.binary_counter4_pulse(one_seg_arch)
        port map (
            clk => clk,
            reset => reset,
            max_pulse => mp2,
            q => q2
        );

    process
    begin
        test_runner_setup(runner, runner_cfg);

        wait for 80 ns;

        test_runner_cleanup(runner);
    end process;
end;
