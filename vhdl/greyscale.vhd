library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Greyscale is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXIS
		C_S00_AXIS_TDATA_WIDTH	: integer	:= 16;
		C_S00_AXIS_TUSER_WIDTH	: integer	:= 1;
		C_S00_AXIS_TDEST_WIDTH	: integer	:= 10
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXIS
		aclk	: in std_logic;
		aresetn	: in std_logic;
		s00_axis_tready	: out std_logic;
		s00_axis_tdata	: in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
		s00_axis_tuser	: in std_logic_vector(C_S00_AXIS_TUSER_WIDTH-1 downto 0);
		s00_axis_tdest	: in std_logic_vector(C_S00_AXIS_TDEST_WIDTH-1 downto 0);
		s00_axis_tlast	: in std_logic;
		s00_axis_tvalid	: in std_logic;
		
				-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_tready	: in std_logic;
		m00_axis_tdata	: out std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
		m00_axis_tuser	: out std_logic_vector(C_S00_AXIS_TUSER_WIDTH-1 downto 0);
		m00_axis_tdest	: out std_logic_vector(C_S00_AXIS_TDEST_WIDTH-1 downto 0);
		m00_axis_tlast	: out std_logic;
		m00_axis_tvalid	: out std_logic
	);
end greyscale;

architecture behave of greyscale is


begin


	-- Add user logic here
	process(aclk)
	begin
	   if rising_edge(aclk) then
	       m00_axis_tdata <= x"7F" & s00_axis_tdata(7 downto 0);
	       s00_axis_tready <= m00_axis_tready;
	       m00_axis_tvalid <= s00_axis_tvalid;
	       m00_axis_tuser <= s00_axis_tuser;
	       m00_axis_tdest <= s00_axis_tdest;
	       m00_axis_tlast <= s00_axis_tlast;
	       if aresetn = '0' then
	           m00_axis_tdata <= x"0000";
	       end if;
	   end if;
    end process;
	-- User logic ends

end behave;
