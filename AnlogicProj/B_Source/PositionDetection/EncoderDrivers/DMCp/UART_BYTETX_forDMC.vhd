library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity UART_BYTETX_forDMC is
	port(   clk  		: in std_logic;	--输入时钟100Mz
			rst  		: in std_logic;
			
			trig		: in std_logic;--消息发送触发信��
			DATA_in		: in std_logic_vector(7 downto 0);--16位并行待发送数��
			TXD			: out std_logic;--数据串行发送端
			Finishpluse	: out std_logic
			);
end UART_BYTETX_forDMC;

architecture UART_BYTETX_forDMC_ARCH of UART_BYTETX_forDMC is 

	type fms_state is (IDEL,SCI_START,
								BITn,Bit_wait,
								SCI_ENDn,END_wait,
								Finish
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
	constant Baud		:	std_LOGIC_VECTOR :=x"0027";--波特率计数值：根据系统时钟与波特率要求进行设置计数��该值需要在实际计算结果��1：因为本代码发送状态机里面加入��clk的Bit_wait环节
	
    signal	Bit_cnt	:	std_logic_vector(4 downto 0);--发送位数计数器
	
	signal	Sci_END_cnt:	std_logic_vector(4 downto 0);--发送结束等待计数器，每帧数据发送完留一定时间间��

begin
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
	
	nextstate_logic:process(present_state,trig,Baud_cnt,Bit_cnt,Sci_END_cnt) --产生次态进程，（组合逻辑电路��
	begin
		case present_state is
			when IDEL => if(trig='1')then
										next_state<=SCI_START;
									else
										next_state<=IDEL;
									end if;							

			when SCI_START => if(Baud_cnt=Baud)then
										next_state<=Bit_wait;
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
										next_state<=SCI_ENDn;
									end if;
			
			when SCI_ENDn => if(Baud_cnt=Baud)then
										next_state<=END_wait;
									else
										next_state<=SCI_ENDn;
									end if;	
							
			when END_wait => 	if(Sci_END_cnt<="00100")then
										next_state<=SCI_ENDn;
									else
										next_state<=Finish;
									end if;
									
			when Finish => next_state<=IDEL;									
			
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
	
	Sci_END_cnt_sig:process(clk,rst,present_state) 
	begin
		if(rst='0')then--异步清零，低电平有效
			Sci_END_cnt<="00000";
		else
			if(rising_edge(clk))then
				if(present_state=IDEL)then
					Sci_END_cnt<="00000";
				elsif(present_state=END_wait)then
					Sci_END_cnt<=Sci_END_cnt+'1';
				else
					Sci_END_cnt<=Sci_END_cnt;
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
				if((present_state=SCI_START)or(present_state=SCI_ENDn)or(present_state=Bitn))then
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
----------数据发��---------------------------------------------------	
------------------------------------------------------------------------
	TXD_sig:process(clk,rst,present_state,Bit_cnt,DATA_in) 
	begin
		if(rst='0')then--异步清零，低电平有效
			TXD<='1';
		else
			if(rising_edge(clk))then
				if((present_state=Bitn)or(present_state=Bit_wait))then
					case Bit_cnt is
						when "00000" => TXD<='0';
						when "00001" => TXD<=DATA_in(0);
						when "00010" => TXD<=DATA_in(1);
						when "00011" => TXD<=DATA_in(2);
						when "00100" => TXD<=DATA_in(3);
						when "00101" => TXD<=DATA_in(4);
						when "00110" => TXD<=DATA_in(5);
						when "00111" => TXD<=DATA_in(6);
						when "01000" => TXD<=DATA_in(7);

						when others  => TXD<='0';
					end case;
				elsif(present_state=SCI_START)then
					TXD<='0';
				else
					TXD<='1';
				end if;
			end if;
		end if;	
	end process;
	

	Finishpluse_sig:process(present_state) 
	begin
        if(present_state=Finish)then
            Finishpluse<='1';
        else
            Finishpluse<='0';
        end if;
	end process;

end 	UART_BYTETX_forDMC_ARCH;