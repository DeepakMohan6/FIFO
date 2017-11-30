library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;    



entity FIFO is
generic 
(
   WIDE  : integer := 8;
   DEPTH : integer := 8;
   DLOG2 : integer := 3

);

port
(
   data : in std_logic_vector(wide-1 downto 0);
   rdclk : in std_logic;
   rdreq : in std_logic;
   wrclk : in std_logic;
   wrreq : in std_logic;
   aclr : in std_logic;
   
   q : out std_logic_vector(wide-1 downto 0);
   rd_empty :  out std_logic;
   rd_full :  out std_logic;
   wr_empty :  out std_logic;
   wr_full :  out std_logic;
   wrusedw :  out std_logic_vector (dlog2-1 downto 0);
   rdusedw :  out std_logic_vector (dlog2-1 downto 0)
   
);
end entity;

architecture behavioral of FIFO is

type RAM is array(depth-1 downto 0) of std_logic_vector(wide-1 downto 0);
signal mem : RAM;

signal wraddr, rdaddr : std_logic_vector (dlog2-1 downto 0);
signal g_wraddr, g_rdaddr : std_logic_vector (dlog2-1 downto 0);

type sync is array(1 downto 0) of std_logic_vector(dlog2-1 downto 0);
signal sync_g_wraddr, sync_g_rdaddr : sync;

signal wraddr_bin, rdaddr_bin : std_logic_vector (dlog2-1 downto 0);
signal wr_diff, rd_diff : std_logic_vector (dlog2-1 downto 0);
signal wraddr_next, rdaddr_next : std_logic_vector (dlog2-1 downto 0);

begin
process(wrclk,aclr)
	begin
	if  (not aclr) = '0' then       
			g_wraddr <= "000";
			sync_g_rdaddr(0) <= "000";
			sync_g_rdaddr(1) <= "000";
			wraddr <= "000";
			wrusedw <= "000";
			
	elsif(rising_edge(wrclk)) then
		sync_g_rdaddr(0) <= g_rdaddr;
		sync_g_rdaddr(1) <= sync_g_rdaddr(0);
		wrusedw <= wr_diff;
			if wrreq = '1' then
				mem(to_integer(unsigned(wraddr))) <= data;
				wraddr <= wraddr_next;
				g_wraddr(DLOG2-1) <= wraddr_next(DLOG2-1);
				for i in 0 to DLOG2-2 loop	
				g_wraddr(i) <= wraddr_next(i+1) xor wraddr_next(i);
				end loop;
			end if;

	end if;
end process;

process(sync_g_rdaddr, rdaddr_bin)
begin
		rdaddr_bin(DLOG2-1) <= sync_g_rdaddr(0)(DLOG2-1);
		for l in DLOG2-2 downto 0 loop
			rdaddr_bin(l) <= rdaddr_bin(l + 1) xor sync_g_rdaddr(1)(l);
		end loop;
  end process;

process (wr_diff)
      begin
			if(wr_diff = "000") then		-- wr_empty = (wrusedw == 0)
				wr_empty <= '1';
			else 
				wr_empty <= '0';				-- wr_full  = (wrusedw == DEPTH - 1)
			end if;
		
			if(wr_diff = "111") then
				wr_full <= '1';
			else 
				wr_full <= '0';
			end if;
end process;

 process(aclr, rdclk)

		begin
		if (not aclr) = '0' then
					g_rdaddr <= "000";
					sync_g_wraddr(0) <= "000";
					sync_g_wraddr(1) <= "000";
					rdaddr <= "000";
					q <= "00000000";
					rdusedw <= "000";
				
		elsif (rising_edge(rdclk)) then
				
					sync_g_wraddr(0) <= g_wraddr;
					sync_g_wraddr(1) <= sync_g_wraddr(0);
					rdusedw <= rd_diff;
					 
						if rdreq = '1' then
							q <= mem(to_integer(unsigned(rdaddr)));
							rdaddr <= rdaddr_next;
							g_rdaddr(DLOG2-1) <= rdaddr_next(DLOG2-1);
							for j in 0 to DLOG2-2 loop
								g_rdaddr(j) <= rdaddr_next(j+1) xor rdaddr_next(j);
							end loop;
						end if;
				
				end if;
			end process;

 process (sync_g_wraddr, wraddr_bin)

		begin
			wraddr_bin(DLOG2-1) <= sync_g_wraddr(1)(DLOG2-1);
			for k in DLOG2-2 downto 0 loop
				wraddr_bin(k) <= wraddr_bin(k+1) xor sync_g_wraddr(1)(k);
			end loop;
		end process;
  
 process(rd_diff)
      begin
      if(rd_diff = "000") then		-- rd_empty = (rdusedw == 0)
			rd_empty <= '1';
		else 
			rd_empty <= '0';
		end if;	
      
		if(rd_diff = "111") then		-- rd_full  = (rdusedw == DEPTH - 1)
			rd_full <= '1';
		else 
			rd_full <= '0';
		end if;
			wraddr_next <= wraddr + 1;
			rdaddr_next <= rdaddr + 1;
	end process;


process(wraddr, rdaddr_bin, wraddr_bin, rdaddr)
		begin
		if wraddr >= rdaddr_bin then
			wr_diff <=wraddr - rdaddr_bin;
		else
			wr_diff <= (not rdaddr_bin - wraddr) + "001";
		end if;
		
		if wraddr_bin > rdaddr then
			rd_diff <= wraddr_bin - rdaddr;
		else
			rd_diff <= (not (rdaddr - wraddr_bin)) + "001";
		end if;
	end process;
end architecture;

