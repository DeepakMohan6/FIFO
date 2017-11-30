
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

 
ENTITY FIFO_TB IS
END FIFO_TB;
 
ARCHITECTURE behavior OF fifo_tb IS 
 
 
    COMPONENT FIFO
    PORT(
         data : IN  std_logic_vector(7 downto 0);
         rdclk : IN  std_logic;
         rdreq : IN  std_logic;
         wrclk : IN  std_logic;
         wrreq : IN  std_logic;
         aclr : IN  std_logic;
         q : OUT  std_logic_vector(7 downto 0);
         rd_empty : OUT  std_logic;
         rd_full : OUT  std_logic;
         wr_empty : OUT  std_logic;
         wr_full : OUT  std_logic;
         wrusedw : OUT  std_logic_vector(2 downto 0);
         rdusedw : OUT  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal data : std_logic_vector(7 downto 0) := (others => '0');
   signal rdclk : std_logic := '0';
   signal rdreq : std_logic := '0';
   signal wrclk : std_logic := '0';
   signal wrreq : std_logic := '0';
   signal aclr : std_logic := '0';

 	--Outputs
   signal q : std_logic_vector(7 downto 0);
   signal rd_empty : std_logic;
   signal rd_full : std_logic;
   signal wr_empty : std_logic;
   signal wr_full : std_logic;
   signal wrusedw : std_logic_vector(2 downto 0);
   signal rdusedw : std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant rdclk_period : time := 6 ns;
   constant wrclk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: FIFO PORT MAP (
          data => data,
          rdclk => rdclk,
          rdreq => rdreq,
          wrclk => wrclk,
          wrreq => wrreq,
          aclr => aclr,
          q => q,
          rd_empty => rd_empty,
          rd_full => rd_full,
          wr_empty => wr_empty,
          wr_full => wr_full,
          wrusedw => wrusedw,
          rdusedw => rdusedw
        );

   -- Clock process definitions
   rdclk_process :process
   begin
		rdclk <= '1';
		wait for rdclk_period/2;
		rdclk <= '0';
		wait for rdclk_period/2;
   end process;
 
   wrclk_process :process
   begin
		wrclk <= '1';
		wait for wrclk_period/2;
		wrclk <= '0';
		wait for wrclk_period/2;
   end process;
 
 	-- Reset process
	clear : process
	begin
		
		aclr <= '1';
		
		wait for 20 ns;
		
		aclr <= '0';

			wait;
	end process;

   wr_proc: process
		variable counter : unsigned (7 downto 0) := (others => '0');
   begin		
     			wait for wrclk_period * 2;

			wrreq <= '1';

			for i in 1 to 8 loop
			
			counter := counter + 1;
			
			data <= std_logic_vector(counter);
			
			wait for wrclk_period * 2;
			
			
		end loop;
					wrreq <= '0';

		
      wait;
   end process;

		rd_proc : process
	begin
		wait for rdclk_period * 20;
		
				
		rdreq <= '1';
		
		wait for rdclk_period * 11;
		
		rdreq <= '0';
		
		
		wait;
	end process;


END;
