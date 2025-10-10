library ieee;
    use ieee.std_logic_1164.all;

entity debounce_filter is
    generic(DEBOUNCE_LIMIT: natural := 20);
    port(clk, bouncy: in std_logic; debounced: out std_logic);
end;

architecture rtl of debounce_filter is
    signal count: natural range 0 to DEBOUNCE_LIMIT := 0;
    signal state: std_logic := '0';
begin
    debounced <= state;

    process
    begin
        -- Wait for the input signal to be stable for a specified amount of
        -- time before allowing the filtered output to change. Essentially,
        -- count the specified number of rising clock edges and then let the
        -- input through.
        wait until rising_edge(clk);
        if (bouncy /= state) and (count < DEBOUNCE_LIMIT) then
            count <= count + 1;
        else
            if DEBOUNCE_LIMIT = count then
                state <= bouncy;
            end if;

            count <= 0;
        end if;
    end process;
end;
