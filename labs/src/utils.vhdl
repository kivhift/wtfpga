package utils is
    function bit_width(x: natural) return natural;
end;

package body utils is
    function bit_width(x: natural) return natural is
        variable c, q: natural;
    begin
        c := 1;
        q := x / 2;
        while q > 0 loop
            q := q / 2;
            c := c + 1;
        end loop;

        return c;
    end;
end;
