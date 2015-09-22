library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity demux1x8 is
	port(	
		in_demux: in std_logic;
		sel: in unsigned(2 downto 0);
		out0: out std_logic;
		out1: out std_logic;
		out2: out std_logic;
		out3: out std_logic;
		out4: out std_logic;
		out5: out std_logic;
		out6: out std_logic;
		out7: out std_logic
	);
end entity;

architecture a_demux1x8 of demux1x8 is
begin
	out0 <= in_demux when sel="000" else '0';
	out1 <= in_demux when sel="001" else '0';
	out2 <= in_demux when sel="010" else '0';
	out3 <= in_demux when sel="011" else '0';
	out4 <= in_demux when sel="100" else '0';
	out5 <= in_demux when sel="101" else '0';
	out6 <= in_demux when sel="110" else '0';
	out7 <= in_demux when sel="111" else '0';
end architecture;
