-- From RTL Hardware Design Using VHDL by Pong P. Chu; Listing 8.12.
library ieee;
    use ieee.std_logic_1164.all, ieee.numeric_std.all;

entity binary_counter4_pulse is
    port (
        clk, reset: in std_logic;
        max_pulse: out std_logic;
        q: out std_logic_vector(3 downto 0)
    );
end;

architecture two_seg_arch of binary_counter4_pulse is
    signal reg_q, reg_d: unsigned(q'range);
begin
    -- register
    process (clk, reset)
    begin
        if reset = '1' then
            reg_q <= (others => '0');
        elsif rising_edge(clk) then
            reg_q <= reg_d;
        end if;
    end process;

    -- next-state logic
    reg_d <= reg_q + 1;

    -- output logic
    max_pulse <= '1' when reg_q = "1111" else '0';
    q <= std_logic_vector(reg_q);
end;

architecture broken_one_seg_arch of binary_counter4_pulse is
    signal reg: unsigned(q'range);
begin
    process (clk, reset)
    begin
        if reset = '1' then
            reg <= (others => '0');
        elsif rising_edge(clk) then
            reg <= reg + 1;
            -- Since this if statement is in the "rising_edge" branch, it
            -- infers a 1-bit register for max_pulse thus delaying it for one
            -- cycle.
            if reg = "1111" then
                max_pulse <= '1';
            else
                max_pulse <= '0';
            end if;
        end if;
    end process;

    q <= std_logic_vector(reg);
end;

architecture one_seg_arch of binary_counter4_pulse is
    signal reg: unsigned(q'range);
begin
    process (clk, reset)
    begin
        if reset = '1' then
            reg <= (others => '0');
        elsif rising_edge(clk) then
            reg <= reg + 1;
        end if;
    end process;

    max_pulse <= '1' when reg = "1111" else '0';
    q <= std_logic_vector(reg);
end;
