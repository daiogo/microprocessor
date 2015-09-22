library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity condition_code_register is
	port( 
		clk: in std_logic;
		enable: in std_logic;
		c_D: in std_logic;
		z_D: in std_logic;
		n_D: in std_logic;
		lt_D: in std_logic;
		c_Q: out std_logic;
		z_Q: out std_logic;
		n_Q: out std_logic;
		lt_Q: out std_logic
	);
end entity;

architecture a_condition_code_register of condition_code_register is

	component flipflopD is
		port( 
			clk: in std_logic;
			enable: in std_logic;
			D: in std_logic;
			Q: out std_logic
		);
	end component;
	
	--signal c_enable_sig,z_enable_sig,n_enable_sig,lt_enable_sig: std_logic;
	--signal c_Q_sig,z_Q_sig,n_Q_sig,lt_Q_sig: std_logic;
	
begin

	--c_enable_sig <= c_D xor c_Q_sig;
	--z_enable_sig <= z_D xor z_Q_sig;
	--n_enable_sig <= n_D xor n_Q_sig;
	--lt_enable_sig <= lt_D xor lt_Q_sig;

	--c_Q <= c_Q_sig;	
	--z_Q <= z_Q_sig;
	--n_Q <= n_Q_sig;
	--lt_Q <= lt_Q_sig;

	ccr_c_ffD: flipflopD port map(clk=>clk,
											enable=>enable,
											D=>c_D,
											Q=>c_Q
										);

	ccr_z_ffD: flipflopD port map(clk=>clk,
											enable=>enable,
											D=>z_D,
											Q=>z_Q
										);

	ccr_n_ffD: flipflopD port map(clk=>clk,
											enable=>enable,
											D=>n_D,
											Q=>n_Q
										);

	ccr_lt_ffD: flipflopD port map(clk=>clk,
											enable=>enable,
											D=>lt_D,
											Q=>lt_Q
										);

end architecture;