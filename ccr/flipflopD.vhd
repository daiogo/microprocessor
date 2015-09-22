library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flipflopD is
	port( 
		clk: in std_logic;
		enable: in std_logic;
		D: in std_logic;
		Q: out std_logic
	);
end entity;

architecture a_flipflopD of flipflopD is

begin
	process(clk,enable)
	begin
		if enable='0' then null;
		elsif rising_edge(clk) then
			Q <= D;
		end if;
	end process;
end architecture;