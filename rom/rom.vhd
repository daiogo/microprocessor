library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity rom is

	port( 
		clk: in std_logic;
		address: in unsigned(10 downto 0);  -- 2^11 addresses
		data: out unsigned(14 downto 0)   	--words are 15 bits wide
	);
end entity;

architecture a_rom of rom is
type mem is array (0 to 64) of unsigned(14 downto 0);
	constant rom_values : mem := (
		0 => "101010000100001",--				lda #33
		1 => "100111110100000",--				mov r5,A		;r5 is the max_number
		
		2 => "101010000000110",--				lda #6
		3 => "100111100100000",--				mov r1,A		;r1 is the square root of max_number
		
		4 => "101010000000001",--				lda #1
		5 => "100111110000000",--				mov r4,A		;r4 is 1
		
		6 => "101010000000000",--				lda #0
		7 => "100111100000000",--				mov r0,A		;r0 is 0
		
		 8 => "101010000000010",--				lda #2			;generate on RAM the list of numbers from 2 to max_number
		 9 => "100111111000000",--list:		mov H,A
		10 => "101100000000000",--				sta
		11 => "000110000000000",--				add r4
		12 => "010110100000000",--				cmp r5
		13 => "110011111111100",--				blt list
		
		14 => "101010000000001",--				lda #1			;initializes ram_iterator
		15 => "100111101100000",--				mov r3,A
		
		16 => "100111011100000",--loop:		mov A,H
		17 => "010100100000000",--				cmp r1
		18 => "011100000010001",--				beq finish		;if all possible multiple numbers are gone, branch to finish
		
		19 => "100101111100000",--				mov A,r3
		20 => "000110000000000",--				add r4			;else, increment ram_iterator
		21 => "100111101100000",--				mov r3,A
		22 => "100111111000000",--				mov H,A
		
		23 => "101000000000000",--				lda
		24 => "010100000000000",--				cmp r0			;if value fetched from memory is 0, branch to the next iteration
		25 => "011111111110111",--				beq loop
		
		26 => "100111011100000",--eliminate:mov A,H			;else, eliminate multiple numbers of ram_iterator
		27 => "000101100000000",--				add r3			;starts to eliminate from the next multiple number
		28 => "100111111000000",--				mov H,A
		
		29 => "101010000000000",--				lda #0			;replaces the multiple number with 0 inside the memory
		30 => "101100000000000",--				sta
		
		31 => "100111011100000",--				mov A,H
		32 => "010110100000000",--				cmp r5
		33 => "110011111111001",--				blt eliminate	;loops until it reaches the max_number
		34 => "011011111101110",--				bra loop
		
		35 => "101010000000010",--finish:	lda #2			;generate on RAM the list of numbers from 2 to max number
		36 => "100111111000000",--display:	mov H,A
		37 => "101000000000000",--				lda
		38 => "010100000000000",--				cmp r0
		39 => "011100000000010",--				beq not_prime
		40 => "100111101000000",--				mov r2,A
		41 => "100111011100000",--not_prime:mov A,H
		42 => "000110000000000",--				add r4
		43 => "010110100000000",--				cmp r5
		44 => "110011111111000",--				blt display
		others => (others=>'0')
	);
begin
	process(clk)
		begin
			if(rising_edge(clk)) then
				data <= rom_values(to_integer(address));
				end if;
	end process;
end architecture;

-----------PROGRAMS-------------

-------------LAB5-------------
--			0 => "101010000000101", --lda #5
--			1 => "100111101100000",	--mov r3,A
--			2 => "101010000001000", --lda #8
--			3 => "100111110000000", --mov r4,A
--			4 => "000101100000000",	--add r3
--			5 => "100111110100000",	--mov r5,A
--			6 => "101010000000001",	--lda #1
--			7 => "100111100000000",	--mov r0,A
--			8 => "100110111100000",	--mov A,r5
--			9 => "001000000000000",	--sub r0
--			10 => "100111110100000",	--mov r5,A
--			11 => "011000000000010",	--bra 0x0D
--			12 => "000000000000000",	--nop
--			13 => "100110101100000",	--mov r3,r5
--			14 => "011011111110101",	--bra 0x03

------------------LAB 6-------------------------
--			0 => "101010000000101", --lda #5
--			1 => "100111101100000",	--mov r3,A
--			2 => "010101100000000", --cmp r3
--			3 => "011100000000100",	--beq 0x07
--			4 => "100111110100000",	--mov r5,A
--			5 => "101010000000001",	--lda #1
--			6 => "101010000000010",	--lda #2
--			7 => "101010000000100",	--lda #4
--			8 => "010101100000000", --cmp r3
--			9 => "110000000000110",	--bmi 0x0F

------------------LAB 7-------------------------
--		--stores 4 on address 30 and stores 5 on address 31
--		0 => "101010000011110",		--			lda #30
--		1 => "100111111000000",		--			mov r6,A
--		2 => "101010000000100",		--			lda #4
--		3 => "101100000000000",		--			sta
--		4 => "101010000011111",		--			lda #31
--		5 => "100111111000000",		--			mov r6,A
--		6 => "101010000000101",		--			lda #5
--		7 => "101100000000000",		--			sta
--		
--		--load values in 30 and 31 and moves it to r0 and r1 respectively
--		8 => "101010000011110",		--			lda #30
--		9 => "100111111000000",		--			mov r6,A
--		10 => "101000000000000",	--			lda
--		11 => "100111100000000",	--			mov r0,A
--		12 => "101010000011111",	--			lda #31
--		13 => "100111111000000",	--			mov r6,A
--		14 => "101000000000000",	--			lda
--		15 => "100111100100000",	--			mov r1,A
--		
--		--stores 10 at address 30
--		16 => "101010000011110",	--			lda #30
--		17 => "100111111000000",	--			mov r6,A
--		18 => "101010000001010",	--			lda #10
--		19 => "101100000000000",	--			sta
--		
--		--stores 1 at address 1
--		20 => "101010000000001",	--			lda #1
--		21 => "100111111000000",	--			mov r6,A
--		22 => "101100000000000",	--			sta
--		
--		--loads address 1 and store it on r2
--		23 => "101000000000000",	--			lda
--		24 => "100111101000000",	--			mov r2,A
--		
--		--loads address 30 and store it on r3
--		25 => "101010000011110",	--			lda #30
--		26 => "100111111000000",	--			mov r6,A
--		27 => "101000000000000",	--			lda
--		28 => "100111101100000",	--			mov r3,A
--		