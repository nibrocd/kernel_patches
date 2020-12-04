library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Threshold is
	generic (
		C_S00_AXIS_TDATA_WIDTH	: integer	:= 16;
		C_S00_AXIS_TUSER_WIDTH	: integer	:= 1;
		C_S00_AXIS_TDEST_WIDTH	: integer	:= 10
	);
	port (
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
		m00_axis_tvalid	: out std_logic;
		
		thresh : in std_logic_vector(7 downto 0) := x"80"
		);
end Threshold;

architecture behave of Threshold is
    signal sig_thresh : std_logic_vector(7 downto 0) := x"80";

begin

	process(aclk)
	begin
	   if rising_edge(aclk) then
	       if unsigned(s00_axis_tdata(7 downto 0)) > unsigned(sig_thresh) then
	           m00_axis_tdata <= x"7FFF";
	       else
	           m00_axis_tdata <= x"7F00";
	       end if;
	       
	       sig_thresh <= thresh;
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

end behave;
