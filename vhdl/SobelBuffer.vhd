library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SobelBuffer is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line
        lineWidth : integer := 640;
        lines : integer := 3;
        totalLines : integer := 480;

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
		s00_axis_tready	: out std_logic := '1';
		s00_axis_tdata	: in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
		s00_axis_tuser	: in std_logic_vector(C_S00_AXIS_TUSER_WIDTH-1 downto 0);
		s00_axis_tdest	: in std_logic_vector(C_S00_AXIS_TDEST_WIDTH-1 downto 0);
		s00_axis_tlast	: in std_logic;
		s00_axis_tvalid	: in std_logic;
		
				-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_tready	: in std_logic;
		m00_axis_tdata	: out std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0) := "0000000000000000";
		m00_axis_tuser	: out std_logic_vector(C_S00_AXIS_TUSER_WIDTH-1 downto 0) := "1";
		m00_axis_tdest	: out std_logic_vector(C_S00_AXIS_TDEST_WIDTH-1 downto 0) := "0000000000";
		m00_axis_tlast	: out std_logic :='0';
		m00_axis_tvalid	: out std_logic :='0';
		
		fclk : std_logic
	);
end SobelBuffer;

architecture behave of SObelBuffer is
signal ena : std_logic_vector(4 downto 0) := "00000";
signal enb : std_logic_vector(4 downto 0) := "00000";
signal wra : std_logic_vector(4 downto 0) := "00000";
signal wrb : std_logic_vector(4 downto 0) := "00000";
signal posa : std_logic_vector(9 downto 0) := (others => '0');
signal posb : std_logic_vector(9 downto 0) := (others => '0');
signal ina : std_logic_vector(7 downto 0) := (others => '0');
signal inb : std_logic_vector(7 downto 0) := (others => '0');
signal out0a, out1a, out2a, out3a, out4a : std_logic_vector(7 downto 0) := (others => '0');
signal out0b, out1b, out2b, out3b, out4b : std_logic_vector(7 downto 0) := (others => '0');

type kernel is array(0 to 3, 0 to 2) of integer range 0 to 255;
signal kern : kernel;

shared variable inLn : std_logic_vector(4 downto 0) := "00001";
shared variable outLn : std_logic_vector(4 downto 0) := "00010";
shared variable pos : integer range 0 to 640 := 0;
shared variable lnCnt : integer range 0 to 480 := 0;
shared variable first : std_logic := '1';

    component rams_tdp_rf_rf is
        port(
            clka  : in  std_logic;
            clkb  : in  std_logic;
            ena   : in  std_logic;
            enb   : in  std_logic;
            wea   : in  std_logic;
            web   : in  std_logic;
            addra : in  std_logic_vector(9 downto 0);
            addrb : in  std_logic_vector(9 downto 0);
            dia   : in  std_logic_vector(7 downto 0);
            dib   : in  std_logic_vector(7 downto 0);
            doa   : out std_logic_vector(7 downto 0);
            dob   : out std_logic_vector(7 downto 0)
        );
    end component rams_tdp_rf_rf;

    -- horizontal sobel kernel
    -- -1 0 1
    -- -2 0 2
    -- -1 0 1
    
     --on pixel clock set values in kernel, then add/subtract, then abs, then replace pixel
begin
LN0: rams_tdp_rf_rf port map (clka=>aclk, clkb=>fclk, ena=>ena(0), enb=>enb(0), wea=>wra(0), web=>wrb(0), addra=>posa, addrb=>posb, dia=>ina, dib=>inb, doa=>out0a, dob=>out0b);
LN1: rams_tdp_rf_rf port map (clka=>aclk, clkb=>fclk, ena=>ena(1), enb=>enb(1), wea=>wra(1), web=>wrb(1), addra=>posa, addrb=>posb, dia=>ina, dib=>inb, doa=>out1a, dob=>out1b);
LN2: rams_tdp_rf_rf port map (clka=>aclk, clkb=>fclk, ena=>ena(2), enb=>enb(2), wea=>wra(2), web=>wrb(2), addra=>posa, addrb=>posb, dia=>ina, dib=>inb, doa=>out2a, dob=>out2b);
LN3: rams_tdp_rf_rf port map (clka=>aclk, clkb=>fclk, ena=>ena(3), enb=>enb(3), wea=>wra(3), web=>wrb(3), addra=>posa, addrb=>posb, dia=>ina, dib=>inb, doa=>out3a, dob=>out3b);
LN4: rams_tdp_rf_rf port map (clka=>aclk, clkb=>fclk, ena=>ena(4), enb=>enb(4), wea=>wra(4), web=>wrb(4), addra=>posa, addrb=>posb, dia=>ina, dib=>inb, doa=>out4a, dob=>out4b);

process(aclk, s00_axis_tvalid, m00_axis_tready)

begin

            wra <= inLn;
            ena <= inLn or outLn;
            ina <= s00_axis_tdata(7 downto 0);
            posa <= std_logic_vector(to_unsigned(pos, 10));




    if rising_edge(aclk) then
    
        m00_axis_tdest <= s00_axis_tdest;
    
        if s00_axis_tvalid = '1' then     
            

            
                
                if lnCnt = 4 then
                    if pos = 1 then
                        m00_axis_tuser(0) <= '1';
                    else
                        m00_axis_tuser(0) <= '0';
                    end if;
                    m00_axis_tvalid <= '1';
                    first := '0';
                    
                elsif lnCnt > 4 or first = '0' then
                    m00_axis_tvalid <= '1';
                    m00_axis_tuser(0) <= '0';
                else
                    m00_axis_tuser(0) <= '0';
                    m00_axis_tvalid <= '0';
                end if;
                
                if m00_axis_tready = '1' or first = '1' then
                    s00_axis_tready <= '1';
                    
                    
                    if outLn = "00001" then
                        m00_axis_tdata <= x"7f" & out0a;
                    elsif outLn = "00010" then
                        m00_axis_tdata <= x"7f" & out1a;
                    elsif outLn = "00100" then
                        m00_axis_tdata <= x"7f" & out2a;
                    elsif outLn = "01000" then
                        m00_axis_tdata <= x"7f" & out3a;
                    elsif outLn = "10000" then
                        m00_axis_tdata <= x"7f" & out4a;
                    end if;
                    
                
                    if pos >= 639 then
                        inLn := inLn(3 downto 0) & inLn(4);
                        outLn := outLn(3 downto 0) & outLn(4);
                        m00_axis_tlast <= '1';
                        pos := 0;
                        
                        if lnCnt >= 479 then
                            lnCnt := 0;
                        else
                            lnCnt := lnCnt+1;
                        end if;
                    else
                        pos := pos +1;
                        m00_axis_tlast <= '0';
                    end if;
                
                else
                    s00_axis_tready <= '0';
                end if;
        
        else
            m00_axis_tvalid <= '0';
        end if;
        
        
        if aresetn = '0' then
            m00_axis_tdata <= x"0000";
            first := '1';
            pos := 0;
            inLn := "00001";
            outLn := "00010";
            lnCnt := 0;
            s00_axis_tready <= '1';
            m00_axis_tuser(0) <= '0';
            m00_axis_tdest <= s00_axis_tdest;
            m00_axis_tlast <= '0';
            m00_axis_tvalid	<= '0';
        end if;
    end if;
end process;


process(fclk)
    variable state : integer range 0 to 3 := 0;
    variable sum : std_logic_vector(7 downto 0);
    variable sum1 : integer range 0 to 1023;
    variable sum2 : integer range 0 to 1023;
    variable sum12 : integer range 0 to 1023;
    variable sum3 : integer range 0 to 1023;
    variable sum4 : integer range 0 to 1023;
    variable sum34 : integer range 0 to 1023;
    variable donePos : integer range 0 to 650 := 0;
    variable nextPos : integer range 0 to 650 := 0;
begin

if rising_edge(fclk) then

    if pos >= 1 and pos <= 637 and donePos /= pos then
        enb <= not(inLn);
        wrb <= outLn;
        
        if state = 0 then   --address data 0
            state := state +1;
            nextPos := pos+2;
            
            if inLn = "10000" then
                kern(3,0) <= to_integer(unsigned(out1b));
                kern(3,1) <= to_integer(unsigned(out2b));
                kern(3,2) <= to_integer(unsigned(out3b));
            elsif inLn = "00001" then
                kern(3,0) <= to_integer(unsigned(out2b));
                kern(3,1) <= to_integer(unsigned(out3b));
                kern(3,2) <= to_integer(unsigned(out4b));
            elsif inLn = "00010" then
                kern(3,0) <= to_integer(unsigned(out3b));
                kern(3,1) <= to_integer(unsigned(out4b));
                kern(3,2) <= to_integer(unsigned(out0b));
            elsif inLn = "00100" then
                kern(3,0) <= to_integer(unsigned(out4b));
                kern(3,1) <= to_integer(unsigned(out0b));
                kern(3,2) <= to_integer(unsigned(out1b));
            elsif inLn = "01000" then
                kern(3,0) <= to_integer(unsigned(out0b));
                kern(3,1) <= to_integer(unsigned(out1b));
                kern(3,2) <= to_integer(unsigned(out2b));
            end if;
            
            sum1 := (kern(0,0) + (kern(1,0)*2) + kern(2,0));
            sum2 := (kern(0,2) + (kern(1,2)*2) + kern(2,2));
            
            sum3 := (kern(2,0) + (kern(2,1)*2) + kern(2,2));
            sum4 := (kern(0,0) + (kern(0,1)*2) + kern(0,2));

            
        elsif state = 1 then --address data 1 get data 0
            state := state +1;
            sum12 := abs(sum1 - sum2);
            sum34 := abs(sum3 - sum4);
            posb <= std_logic_vector(to_unsigned(pos, 10));
              
        elsif state = 2 then --sum
            sum := std_logic_vector(to_unsigned( ((sum12 + sum34)/8), 8));
            inb <= sum;
            donePos := pos;
            
            kern(0,0) <= kern(1,0);
            kern(0,1) <= kern(1,1);
            kern(0,2) <= kern(1,2);
            
            kern(1,0) <= kern(2,0);
            kern(1,1) <= kern(2,1);
            kern(1,2) <= kern(2,2);
            
            kern(2,0) <= kern(3,0);
            kern(2,1) <= kern(3,1);
            kern(2,2) <= kern(3,2);
            posb <= std_logic_vector(to_unsigned(nextPos, 10));
            state := 0;
        end if;
        
    elsif pos = 0 then
        enb <= not(inLn);
        
        if state = 0 then
            state := state +1;
            kern(0,0) <= kern(1,0);
            kern(0,1) <= kern(1,1);
            kern(0,2) <= kern(1,2);
            
            kern(1,0) <= kern(2,0);
            kern(1,1) <= kern(2,1);
            kern(1,2) <= kern(2,2);
            
            kern(2,0) <= kern(3,0);
            kern(2,1) <= kern(3,1);
            kern(2,2) <= kern(3,2);
            posb <= std_logic_vector(to_unsigned(pos+1, 10));
            
            
        elsif state = 1 then --address data 1 get data 0

            posb <= std_logic_vector(to_unsigned(pos, 10));
            if inLn = "10000" then
                kern(3,0) <= to_integer(unsigned(out1b));
                kern(3,1) <= to_integer(unsigned(out2b));
                kern(3,2) <= to_integer(unsigned(out3b));
            elsif inLn = "00001" then
                kern(3,0) <= to_integer(unsigned(out2b));
                kern(3,1) <= to_integer(unsigned(out3b));
                kern(3,2) <= to_integer(unsigned(out4b));
            elsif inLn = "00010" then
                kern(3,0) <= to_integer(unsigned(out3b));
                kern(3,1) <= to_integer(unsigned(out4b));
                kern(3,2) <= to_integer(unsigned(out0b));
            elsif inLn = "00100" then
                kern(3,0) <= to_integer(unsigned(out4b));
                kern(3,1) <= to_integer(unsigned(out0b));
                kern(3,2) <= to_integer(unsigned(out1b));
            elsif inLn = "01000" then
                kern(3,0) <= to_integer(unsigned(out0b));
                kern(3,1) <= to_integer(unsigned(out1b));
                kern(3,2) <= to_integer(unsigned(out2b));
            end if;
            
            state := 0;
        end if;
    end if;
end if;

end process;


end behave;
