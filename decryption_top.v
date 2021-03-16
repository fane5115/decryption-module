`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:12:00 11/23/2020 
// Design Name: 
// Module Name:    demux 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module decryption_top#(
			parameter addr_witdth = 8,
			parameter reg_width 	 = 16,
			parameter MST_DWIDTH = 32,
			parameter SYS_DWIDTH = 8
		)(
		// Clock and reset interface
		input clk_sys,
		input clk_mst,
		input rst_n,
		
		// Input interface
		input [MST_DWIDTH -1 : 0] data_i,
		input 						  valid_i,
		output busy,
		
		//output interface
		output [SYS_DWIDTH - 1 : 0] data_o,
		output      					 valid_o,
		
		// Register access interface
		input[addr_witdth - 1:0] addr,
		input read,
		input write,
		input [reg_width - 1 : 0] wdata,
		output[reg_width - 1 : 0] rdata,
		output done,
		output error
    );
	
	wire[reg_width - 1 : 0] select;
	wire[reg_width - 1 : 0] caesar_key;
	wire[reg_width - 1 : 0] scytale_key;
	wire[reg_width - 1 : 0] zigzag_key;

	wire [SYS_DWIDTH - 1 : 0] 	data0_o;
	wire     					valid0_o;
	
	wire [SYS_DWIDTH - 1 : 0] 	data1_o;
	wire     					valid1_o;
	
	wire [SYS_DWIDTH - 1 : 0] 	data2_o;
	wire     					valid2_o;

	wire [ SYS_DWIDTH - 1: 0 ] 	data_caesar;
	wire 						valid_caesar;

	wire [ SYS_DWIDTH - 1: 0 ] 	data_scytale;
	wire 						valid_scytale;

	wire [ SYS_DWIDTH - 1: 0 ] 	data_zigzag;
	wire 						valid_zigzag;

	wire busy0, busy1, busy2;

	decryption_regfile #( addr_witdth, reg_width ) regs ( clk_sys, rst_n, addr, read, write, wdata, rdata, done, error, select, caesar_key, scytale_key, zigzag_key ); 

	demux #( MST_DWIDTH, SYS_DWIDTH ) dmx ( clk_sys, clk_mst, rst_n, select[1:0], data_i, valid_i, data0_o, valid0_o, data1_o, valid1_o, data2_o, valid2_o );

	caesar_decryption #( SYS_DWIDTH, reg_width ) caesar ( clk_sys, rst_n, data0_o, valid0_o, caesar_key, busy0, data_caesar, valid_caesar ) ;
	scytale_decryption #( SYS_DWIDTH, SYS_DWIDTH, 50, 8'hFA ) scytale ( clk_sys, rst_n, data1_o, valid1_o, scytale_key[ 15 : 8 ], scytale_key[ 7 : 0 ], data_scytale, valid_scytale, busy1 );
	zigzag_decryption #( SYS_DWIDTH, SYS_DWIDTH, 50, 8'hFA ) zigzag ( clk_sys, rst_n, data2_o, valid2_o, zigzag_key[ 7 : 0 ], busy2, data_zigzag, valid_zigzag );

	mux #( SYS_DWIDTH ) mux ( clk_sys, rst_n, select[1:0], data_o, valid_o, data_caesar, valid_caesar, data_scytale, valid_scytale, data_zigzag, valid_zigzag );

	assign busy = busy0 | busy1 | busy2;

endmodule
