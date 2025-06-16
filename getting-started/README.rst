Contained herein are the projects from "Getting Started with FPGAs" by Russell
Merrick.

As a first pass, just have test benches for the projects.

Initially using Questa Sim 2019.3 for simulation along with VUnit 4.7.0 to
drive things. Questa Sim 2021.4 has also worked. On Linux, GHDL 5.0.1,
installed from source, using the mcode backend, works using the same version of
VUnit. However, VUnit had to be tweaked since the new version of GHDL broke
VUnit's backend-finding regular expression. The mcode stuff is JITted now, it
seems.
