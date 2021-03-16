`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:13:49 11/23/2020 
// Design Name: 
// Module Name:    decryption_regfile 
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
module decryption_regfile #(
			parameter addr_witdth = 8,
			parameter reg_width 	 = 16
		)(
			// Clock and reset interface
			input clk, 
			input rst_n,
			
			// Register access interface
			input[addr_witdth - 1:0] addr,
			input read,
			input write,
			input [reg_width -1 : 0] wdata,
			output reg [reg_width -1 : 0] rdata,
			output reg done,
			output reg error,
			
			// Output wires
			output reg[reg_width - 1 : 0] select,
			output reg[reg_width - 1 : 0] caesar_key,
			output reg[reg_width - 1 : 0] scytale_key,
			output reg[reg_width - 1 : 0] zigzag_key
    );
	
	always @( posedge clk) begin
		if(!rst_n) begin
				select <= 16'h0;
				caesar_key <= 16'h0;
				scytale_key <= 16'hFFFF;
				zigzag_key <= 16'h2;
				error <= 0;
				done <= 0;
		rdata <= 16'h0;
		end 
		else begin
			error <= 0; // dupa un ciclu de ceas aducem inapoi la 0 error si done
			done <= 0;
			case (addr) 
				8'h0:begin
					if(write) begin
						select <= wdata[1:0];
						done <= 1;
					end
					else if(read ) begin
						done <= 1;
						rdata <= select;
					end
				end
				
				8'h10: begin
					if(write) begin
						caesar_key <= wdata;
						done <= 1;
					end
					else if( read ) begin
						rdata <= caesar_key;
						done <= 1;
					end
				end
				
				8'h12: begin
					if(write) begin
						scytale_key <= wdata;
						done <= 1;
					end
					else if( read ) begin
						rdata <= scytale_key;
						done <= 1;
					end
				end
				
				8'h14: begin
					if(write) begin
						zigzag_key <= wdata;
						done <= 1;
					end
					else if( read ) begin
						rdata <= zigzag_key;
						done <= 1;
					end
				end
				
				default: begin
						error <= 1;
						done <= 1;
				end
			endcase
		end 
		
	end

endmodule
