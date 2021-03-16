`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:24:12 11/27/2020 
// Design Name: 
// Module Name:    scytale_decryption 
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
module scytale_decryption#(
			parameter D_WIDTH = 8, 
			parameter KEY_WIDTH = 8, 
			parameter MAX_NOF_CHARS = 50,
			parameter START_DECRYPTION_TOKEN = 8'hFA
		)(
			// Clock and reset interface
			input clk,
			input rst_n,
			
			// Input interface
			input[D_WIDTH - 1:0] data_i,
			input valid_i,
			
			// Decryption Key
			input[KEY_WIDTH - 1 : 0] key_N,
			input[KEY_WIDTH - 1 : 0] key_M,
			
			// Output interface
			output reg[D_WIDTH - 1:0] data_o,
			output reg valid_o,
			
			output reg busy
    );


	integer i;
	integer j;
	reg [ D_WIDTH -1:0] aux [ MAX_NOF_CHARS - 1 : 0 ]; // folosim un vector pentru a stoca datele
	
	always @( posedge clk ) begin
		data_o <= 0;
		if( !rst_n ) begin
			data_o <= 0;
			valid_o <= 0;
			busy <= 0;
			i <= 0;
			j <= 0;
		end 
		else begin
			if(valid_i)begin
				//busy <= 0;
				aux[i] <= data_i;
				i <= i+1;
				if( data_i == START_DECRYPTION_TOKEN ) begin
					busy <= 1;
					i <= 0;
					j <= 1; //cum incepem deja de pe pozitia de inceput atunci cand iesim din vector ne ajuta sa trecem pe pozitia urmatoare
				end
			end 
			if(busy) begin
				valid_o <= 1;
				if( j == key_N+1 ) begin 
					valid_o <= 0;
					busy <= 0;
					i <= 0;
					j <= 0;
				end else begin
					if( i < key_N * key_M ) begin // mergem in key_N pasi pana iesim din vector
						data_o <= aux[i];
						i <= i + key_N;	
					end
					
					if( i+key_N >= key_N * key_M ) begin // daca am iesit din vecor revenim la inceput dar pe urmatoarea pozitie
						j <= j+1;
						i <= j;
					end
				end
			end
		end
	end


endmodule
