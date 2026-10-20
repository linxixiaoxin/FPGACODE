library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity UART_BYTERX_forDMC is
	port(   clk  		: in std_logic;	--clkin 100Mhz
			rst  		: in std_logic;
			RXD			: in std_logic;--数据串行接收��
			DATA_RX		: out std_logic_vector(7 downto 0);
			RXPluse		: out std_logic--数据接收脉冲
			);
end UART_BYTERX_forDMC;

architecture UART_BYTERX_forDMC_ARCH of UART_BYTERX_forDMC is 

	type fms_state is (IDEL,SCI_START,
								BITn,Bit_wait,
								SCI_END
								);	--发送状态机定义
	signal present_state,next_state : fms_state;
	
	signal	Baud_cnt	:	std_logic_vector(15 downto 0);--波特率计数器
    
    --9600bps   ->x"28B0"
    --115200bps ->x"0363"
    --1Mbps     ->x"0063"
    --1.5Mbps   ->x"0042"
    --2Mbps     ->x"0031"
    --2.5Mbps   ->x"0027"
    --3Mbps     ->x"0020"
    --3.5Mbps   ->x"001C"
    --4Mbps     ->x"0018"
	constant Baud		:	std_LOGIC_VECTOR :=x"0027";
    signal  BaudSet     :   std_logic_vector(15 downto 0);
    signal  SampingBase	:	std_logic_vector(15 downto 0);                                                              
    signal  Samping1	:	std_logic_vector(15 downto 0);
    signal  Samping2	:	std_logic_vector(15 downto 0);
    signal  Samping3	:	std_logic_vector(15 downto 0);
	
	signal	Bit_cnt	:	std_logic_vector(4 downto 0);--接收位数计数器，本代码须接收8位数��

	
	signal	trig	:	std_logic;--该信号表征起始位，检测RXD的下降沿
	signal	RXD1	:	std_logic;--RXD同步信号
	signal	RXD2	:	std_logic;--RXD1延迟1��

	signal	RXD_samp:std_logic_vector(2 downto 0) ;--接收采样2,1,0
	signal	RXD_Filter:std_logic;--选取多数值为该位接收到的电平(RXD_samp2,RXD_samp1,RXD_samp0三选多)
	
	signal	RXD_DATA_buffer:std_logic_vector(7 downto 0);--接收并行数据缓冲
	
    signal	RXPluse_pre	:	std_logic;--
    
begin
    BaudSet<=Baud;
    SampingBase<=BaudSet(15)&BaudSet(15)&BaudSet(15 downto 2);
    Samping1<=SampingBase;
    Samping2<=Samping1+SampingBase;
    Samping3<=Samping2+SampingBase;
    
    
	RXD1_sig:process(clk,rst,RXD) 
	begin
		if(rst='0')then--异步清零，低电平有效
			RXD1<='1';
		else
			if(rising_edge(clk))then
				RXD1<=RXD;
			end if;
		end if;	
	end process;
	
	RXD2_sig:process(clk,rst,RXD1) 
	begin
		if(rst='0')then--异步清零，低电平有效
			RXD2<='1';
		else
			if(rising_edge(clk))then
				RXD2<=RXD1;
			end if;
		end if;	
	end process;	
	

	trig<=(not RXD1) and RXD2;--下降沿检��
	----------------------------------------------------------------------------------------------------------------------------------------
	---------数据发送状态机----------------↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓��
	----------------------------------------------------------------------------------------------------------------------------------------
	state_register:process(clk,rst)         --产生状态寄存器时序进程,时钟上升沿触发，（时序逻辑电路��
	begin
		if(rst='0')then--异步清零，低电平有效
			present_state<=IDEL;
		else
			if(rising_edge(clk))then
				present_state<=next_state;
			end if;
		end if;	
	end process;
	
	---------------------------------------
	
	nextstate_logic:process(present_state,trig,Baud_cnt,Bit_cnt,RXD_Filter,Samping3) --产生次态进程，（组合逻辑电路��
	begin
		case present_state is
			when IDEL => if(trig='1')then
										next_state<=SCI_START;
									else
										next_state<=IDEL;
									end if;							

			when SCI_START => if(Baud_cnt=Baud)then
										if(RXD_Filter='0')then
											next_state<=Bit_wait;
										else
											next_state<=IDEL;
										end if;
									else
										next_state<=SCI_START;
									end if;	
									
			when Bitn => 		if(Baud_cnt=Baud)then
										next_state<=Bit_wait;
									else
										next_state<=Bitn;
									end if;
									
			when Bit_wait => if(Bit_cnt<"01000")then
										next_state<=Bitn;
									else
										next_state<=SCI_END;
									end if;
			
			when SCI_END => if(Baud_cnt>=Samping3)then--if(Baud_cnt=Baud)then
											next_state<=IDEL;	

									else
										next_state<=SCI_END;
									end if;									
			
			when others => next_state<=IDEL;
																 
		end case;
	end process;		
	
	
------------------------------------------------------------------------	
----------发送位数计数器，以及帧间隔位数计数��-----------------------------	
------------------------------------------------------------------------	
	Bit_cnt_sig:process(clk,rst,present_state) 
	begin
		if(rst='0')then--异步清零，低电平有效
			Bit_cnt<="00000";
		else
			if(rising_edge(clk))then
				if(present_state=IDEL)then
					Bit_cnt<="00000";
				elsif(present_state=Bit_wait)then
					Bit_cnt<=Bit_cnt+'1';
				else
					Bit_cnt<=Bit_cnt;
				end if;
			end if;
		end if;	
	end process;	
	
------------------------------------------------------------------------	
----------波特率计数器----------------------------------------------------	
------------------------------------------------------------------------
	Baud_cnt_sig:process(clk,rst,present_state) 
	begin
		if(rst='0')then--异步清零，低电平有效
			Baud_cnt<=x"0000";
		else
			if(rising_edge(clk))then
				if((present_state=SCI_START)or(present_state=SCI_END)or(present_state=Bitn))then
					if(Baud_cnt<Baud)then
						Baud_cnt<=Baud_cnt+'1';
					else
						Baud_cnt<=Baud_cnt;
					end if;	
				else 
					Baud_cnt<=x"0000";
				end if;
			end if;
		end if;	
	end process;	
------------------------------------------------------------------------	
----------数据采样----------------------------------------------------	
------------------------------------------------------------------------
	RXD_samp_sig:process(clk,rst,present_state,RXD1) 
	begin
		if(rst='0')then--异步清零，低电平有效
			RXD_samp<="000";
		else
			if(rising_edge(clk))then
				if((present_state=SCI_START)or(present_state=Bitn))then
					if(Baud_cnt=Samping1)then
						RXD_samp(2)<=RXD1;
					elsif(Baud_cnt=Samping2)then
						RXD_samp(1)<=RXD1;
					elsif(Baud_cnt=Samping3)then
						RXD_samp(0)<=RXD1;
					end if;
				end if;
			end if;
		end if;	
	end process;

	
	RXD_Filter_sig:process(clk,rst,RXD_samp) 
	begin
		if(rst='0')then--异步清零，低电平有效
			RXD_Filter<='1';
		else
			if(rising_edge(clk))then
				case RXD_samp is
					when "000"	 => 	RXD_Filter<='0';
					when "001"	 => 	RXD_Filter<='0';
					when "010"	 => 	RXD_Filter<='0';
					when "011"	 => 	RXD_Filter<='1';
					when "100"	 => 	RXD_Filter<='0';
					when "101"	 => 	RXD_Filter<='1';
					when "110"	 => 	RXD_Filter<='1';
					when "111"	 => 	RXD_Filter<='1';
					
					when others	 =>	RXD_Filter<='1';
				end case;
			end if;
		end if;	
	end process;		
------------------------------------------------------------------------	
----------数据采样----------------------------------------------------	
------------------------------------------------------------------------	
	RXD_DATA_buffer_sig:process(clk,rst,present_state,Bit_cnt,RXD_Filter) 
	begin
		if(rst='0')then--异步清零，低电平有效
			RXD_DATA_buffer<=x"00";
		else
			if(rising_edge(clk))then
				if(present_state=Bit_wait)then
					case Bit_cnt is
						when "00001"	 => 	RXD_DATA_buffer(0)<=RXD_Filter;
						when "00010"	 => 	RXD_DATA_buffer(1)<=RXD_Filter;
						when "00011"	 => 	RXD_DATA_buffer(2)<=RXD_Filter;
						when "00100"	 => 	RXD_DATA_buffer(3)<=RXD_Filter;
						when "00101"	 => 	RXD_DATA_buffer(4)<=RXD_Filter;
						when "00110"	 => 	RXD_DATA_buffer(5)<=RXD_Filter;
						when "00111"	 => 	RXD_DATA_buffer(6)<=RXD_Filter;
						when "01000"	 => 	RXD_DATA_buffer(7)<=RXD_Filter;
						when others	 => 	RXD_DATA_buffer<=RXD_DATA_buffer;
					end case;
				end if;
			end if;
		end if;	
	end process;	

	DATA_RX_sig:process(clk,rst,present_state,RXD_DATA_buffer,Baud_cnt) 
	begin
		if(rst='0')then--异步清零，低电平有效
			DATA_RX<=x"00";
		else
			if(rising_edge(clk))then
				if((present_state=SCI_END)and(Baud_cnt=Samping3))then
					DATA_RX<=RXD_DATA_buffer;
				end if;
			end if;
		end if;	
	end process;

    RXPluse_pre_sig:process(clk,rst,present_state,Baud_cnt) 
	begin
		if(rst='0')then--异步清零，低电平有效
			RXPluse_pre<='0';
		else
			if(rising_edge(clk))then
				if((present_state=SCI_END)and(Baud_cnt=Samping3))then
					RXPluse_pre<='1';
                else
                    RXPluse_pre<='0';
				end if;
			end if;
		end if;	
	end process;
    
    RXPluse_sig:process(clk,rst,RXPluse_pre) 
	begin
		if(rst='0')then--异步清零，低电平有效
			RXPluse<='0';
		else
			if(rising_edge(clk))then
                RXPluse<=RXPluse_pre;
			end if;
		end if;	
	end process;
    
    
end 	UART_BYTERX_forDMC_ARCH;