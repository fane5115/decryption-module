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

module demux #(
		parameter MST_DWIDTH = 32,
		parameter SYS_DWIDTH = 8
	)(
		// Clock and reset interface
		input clk_sys,
		input clk_mst,
		input rst_n,
		
		//Select interface
		input[1:0] select,
		
		// Input interface
		input [MST_DWIDTH -1  : 0]	 		data_i,
		input 						 	 	valid_i,
		
		//output interfaces
		output reg [SYS_DWIDTH - 1 : 0] 	data0_o,
		output reg    						valid0_o,
		
		output reg [SYS_DWIDTH - 1 : 0] 	data1_o,
		output reg     						valid1_o,
		
		output reg [SYS_DWIDTH - 1 : 0] 	data2_o,
		output reg     						valid2_o
    );
	

	reg [ MST_DWIDTH - 1 : 0 ] aux, aux1;
	integer i = 0, j;
	reg ok;
	
	always @(posedge clk_sys) begin
		if( !rst_n ) begin
			data0_o <= 0;
			data1_o <= 0;
			data2_o <= 0;
			i <= 0;
			j <= 4;
		end
		else begin
			if ( valid_i || valid0_o || valid1_o || valid2_o) begin
				if( i == 3 ) begin
					i <= 0;
				end
				else if( i == 2 ) begin
					aux <= data_i;
					i <= i + 1;
					ok <= 1; //folosim ok pentru a adauga datele in data_o in momentul in care valid_o este 1
				end
				else i <= i + 1;
			end 
			else begin 
				ok <= 0;
				j <= 4;
			end

			case (select)
				0: begin
					if(ok) begin
						data0_o <= aux[ (j*8-1) -: 8 ];
						if( j == 1 )
							j <= 4;
						else j <= j - 1;
					end
				end
				1: begin
					if(ok) begin
						data1_o <= aux[ (j*8-1) -: 8 ];
						if( j == 1 )
							j <= 4;
						else j <= j - 1;
					end
				end
				2: begin
					if(ok) begin
						data2_o <= aux[ (j*8-1) -: 8 ];
						if( j == 1 )
							j <= 4;
						else j <= j - 1;
					end
				end
				default: begin
					data0_o <= 0;
					data1_o <= 0;
					data2_o <= 0;
					j <= 4;
				end
			endcase
		end
	end
	
	always @(posedge clk_mst) begin
		if( !rst_n ) begin
			valid0_o <= 0;
			valid1_o <= 0;
			valid2_o <= 0;
		end
		else begin
			if( valid_i ) begin
				case (select)
					
					0: begin
						valid0_o <= 1;
					end
					
					1: begin
						valid1_o <= 1;
					end
					2: begin
						valid2_o <= 1;
					end
					default: begin
						valid0_o <= 0;
						valid1_o <= 0;
						valid2_o <= 0;
					end	
				endcase
			end
			else begin
				valid0_o <= 0;
				valid1_o <= 0;
				valid2_o <= 0;
			end
		end
	end
endmodule
