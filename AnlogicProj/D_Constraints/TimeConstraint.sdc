create_clock -name CLKin -period 10 -waveform {0 5} [get_ports {clk}] -add
create_clock -name rstin -period 1000 -waveform {0 500} [get_nets {FourAxisesDriver/rst}]
create_generated_clock -add -name CLK100Mhz -source [get_ports {clk}] -master_clock {CLKin} -phase 0 -multiply_by 1 [get_nets {FourAxisesDriver/SysPLL_inst/Clk_100Mhz}]
create_generated_clock -add -name CLK50Mhz -source [get_ports {clk}] -master_clock {CLKin} -phase 0 -multiply_by 0.5 [get_nets {FourAxisesDriver/SysPLL_inst/Clk_50Mhz}]
create_generated_clock -add -name CLK20Mhz -source [get_ports {clk}] -master_clock {CLKin} -phase 0 -multiply_by 0.2 [get_nets {FourAxisesDriver/SysPLL_inst/Clk_20Mhz}]
create_clock -name SPICLK -period 50 -waveform {0 25} [get_ports {SPI_CLK}] -add
set_input_delay -clock [get_clocks {CLK20Mhz}] -max 20 -add_delay [get_ports {A_MDATU A_MDATV B_MDATU B_MDATV C_MDATU C_MDATV D_MDATU D_MDATV}]
set_input_delay -clock [get_clocks {CLK20Mhz}] -min 1 -add_delay [get_ports {A_MDATU A_MDATV B_MDATU B_MDATV C_MDATU C_MDATV D_MDATU D_MDATV}]
create_clock -name PHY1REFCLK50 -period 20 -waveform {0 10} [get_ports {PHY_REFCLK}] -add
create_clock -name PHY2REFCLK50 -period 20 -waveform {0 10} [get_ports {PHY_REFCLK2}] -add
set_input_delay -clock [get_clocks {PHY1REFCLK50}] -max 5 -add_delay [get_ports {PHY_CRSDV PHY_RXD[0] PHY_RXD[1]}]
set_input_delay -clock [get_clocks {PHY1REFCLK50}] -min 0 -add_delay [get_ports {PHY_CRSDV PHY_RXD[0] PHY_RXD[1]}]
set_input_delay -clock [get_clocks {PHY2REFCLK50}] -max 5 -add_delay [get_ports {PHY_CRSDV2 PHY_RXD2[0] PHY_RXD2[1]}]
set_input_delay -clock [get_clocks {PHY2REFCLK50}] -min 0 -add_delay [get_ports {PHY_CRSDV2 PHY_RXD2[0] PHY_RXD2[1]}]
set_output_delay -clock [get_clocks {PHY1REFCLK50}] -max 10 -add_delay [get_ports {PHY_TXEN PHY_TXD[0] PHY_TXD[1]}]
set_output_delay -clock [get_clocks {PHY1REFCLK50}] -min 5 -add_delay [get_ports {PHY_TXEN PHY_TXD[0] PHY_TXD[1]}]
set_output_delay -clock [get_clocks {PHY2REFCLK50}] -max 10 -add_delay [get_ports {PHY_TXEN2 PHY_TXD2[0] PHY_TXD2[1]}]
set_output_delay -clock [get_clocks {PHY2REFCLK50}] -min 5 -add_delay [get_ports {PHY_TXEN2 PHY_TXD2[0] PHY_TXD2[1]}]
set_clock_groups -exclusive -group [get_clocks {rstin}] -group [get_clocks {CLK100Mhz}] -group [get_clocks {CLK20Mhz}] -group [get_clocks {CLK50Mhz}] -group [get_clocks {SPICLK}] -group [get_clocks {CLKin}] -group [get_clocks {PHY1REFCLK50}] -group [get_clocks {PHY2REFCLK50}]]


#create_clock -name CLKin -period 40 -waveform {0 20} [get_ports {clk}] -add
#create_clock -name rstin -period 1000 -waveform {0 500} [get_nets {FourAxisesDriver/rst}]
#create_generated_clock -add -name CLK100Mhz -source [get_ports {clk}] -master_clock {CLKin} -phase 0 -multiply_by 4 [get_nets {FourAxisesDriver/SysPLL_inst/Clk_100Mhz}]
#create_generated_clock -add -name CLK50Mhz -source [get_ports {clk}] -master_clock {CLKin} -phase 0 -multiply_by 2 [get_nets {FourAxisesDriver/SysPLL_inst/Clk_50Mhz}]
#create_generated_clock -add -name CLK20Mhz -source [get_ports {clk}] -master_clock {CLKin} -phase 0 -multiply_by 0.8 [get_nets {FourAxisesDriver/SysPLL_inst/Clk_20Mhz}]
#create_clock -name SPICLK -period 50 -waveform {0 25} [get_ports {SPI_CLK}] -add
#set_input_delay -clock [get_clocks {CLK20Mhz}] -max 20 -add_delay [get_ports {A_MDATU A_MDATV B_MDATU B_MDATV C_MDATU C_MDATV D_MDATU D_MDATV}]
#set_input_delay -clock [get_clocks {CLK20Mhz}] -min 1 -add_delay [get_ports {A_MDATU A_MDATV B_MDATU B_MDATV C_MDATU C_MDATV D_MDATU D_MDATV}]
#create_clock -name PHY1REFCLK50 -period 20 -waveform {0 10} [get_ports {PHY_REFCLK}] -add
#create_clock -name PHY2REFCLK50 -period 20 -waveform {0 10} [get_ports {PHY_REFCLK2}] -add
#set_input_delay -clock [get_clocks {PHY1REFCLK50}] -max 5 -add_delay [get_ports {PHY_CRSDV PHY_RXD[0] PHY_RXD[1]}]
#set_input_delay -clock [get_clocks {PHY1REFCLK50}] -min 0 -add_delay [get_ports {PHY_CRSDV PHY_RXD[0] PHY_RXD[1]}]
#set_input_delay -clock [get_clocks {PHY2REFCLK50}] -max 5 -add_delay [get_ports {PHY_CRSDV2 PHY_RXD2[0] PHY_RXD2[1]}]
#set_input_delay -clock [get_clocks {PHY2REFCLK50}] -min 0 -add_delay [get_ports {PHY_CRSDV2 PHY_RXD2[0] PHY_RXD2[1]}]
#set_output_delay -clock [get_clocks {PHY1REFCLK50}] -max 10 -add_delay [get_ports {PHY_TXEN PHY_TXD[0] PHY_TXD[1]}]
#set_output_delay -clock [get_clocks {PHY1REFCLK50}] -min 5 -add_delay [get_ports {PHY_TXEN PHY_TXD[0] PHY_TXD[1]}]
#set_output_delay -clock [get_clocks {PHY2REFCLK50}] -max 10 -add_delay [get_ports {PHY_TXEN2 PHY_TXD2[0] PHY_TXD2[1]}]
#set_output_delay -clock [get_clocks {PHY2REFCLK50}] -min 5 -add_delay [get_ports {PHY_TXEN2 PHY_TXD2[0] PHY_TXD2[1]}]
#set_clock_groups -exclusive -group [get_clocks {rstin}] -group [get_clocks {CLK100Mhz}] -group [get_clocks {CLK20Mhz}] -group [get_clocks {CLK50Mhz}] -group [get_clocks {SPICLK}] -group [get_clocks {CLKin}] -group [get_clocks {PHY1REFCLK50}] -group [get_clocks {PHY2REFCLK50}]]