`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:33:04 11/23/2020 
// Design Name: 
// Module Name:    zigzag_decryption 
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
module zigzag_decryption #(
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
			input[KEY_WIDTH - 1 : 0] key,
			
			// Output interface
			output reg busy,
			output reg[D_WIDTH - 1:0] data_o,
			output reg valid_o
    );

	`define MAX_CHARS 50 

	reg [ D_WIDTH -1:0] 		aux 	[ MAX_NOF_CHARS - 1 : 0 ]; 
	reg [ KEY_WIDTH - 1: 0 ] 	cycle;
	reg [ KEY_WIDTH - 1: 0 ] 	base_width, base_width1;
	reg 						ok;
	integer 					i, j, k, len, m;
	reg 						valid;
	always @( posedge clk ) begin
		if( !rst_n ) begin
			busy <= 0;
			data_o <= 0;
			valid_o <= 0;
			i <= 0;
			cycle <= 0;
			j <= 0;
			k <= 0;
			base_width <= 0;
			base_width1 <= 0;
			ok <= 0;
			m <= 0;
			valid <= 1;
		end
		else begin
			cycle <= key*2 - 2; //calculam perioada elementelor de pe prima linie
			if(valid_i && valid )begin
				//busy <= 0;
				aux[i] <= data_i;
				i <= i+1;
				if( data_i == START_DECRYPTION_TOKEN ) begin
					busy <= 1;
					valid <= 0;
					j <= 0;
					k <= 0;
					len <= i;
					if( key == 2 ) begin
						if( i != ( i >> 1 ) * cycle )	// calculam cate elemente avem pe prima linie
							base_width <= ( i >> 1 ) + 1;
						else base_width <= ( i >> 1 );
					end
					else begin
						if( i != ( i >> 2 ) * cycle )
							base_width <= ( i >> 2 ) + 1;
						else base_width <= ( i >> 2 );
					end
					i <= 0;
					ok <= 1;
				end
			end 
			if(busy) begin
				valid_o <= 1;
				if(ok) begin
					base_width1 <= base_width;
					ok <= 0;
				end
				if(key) begin 
						if( k < len ) begin
							if( m < base_width ) begin // mergem pana am atins toate elementele de pe prima linie
								if ( j < cycle ) begin	// mergem o perioada de [cycle] elemente
									if( j == 0 ) begin
										data_o <= aux[m];
									end
									else if( j == 3 || j == 1 ) begin
										data_o <= aux[ base_width1 ];
										base_width1 <= base_width1 + 1;
									end
									else begin
										data_o <= aux[ len - ( ( ( len - 3 ) >> 2 ) + 1 ) + m ];
									end
									
									if( j == cycle - 1 ) begin
										j <= 0;
										m <= m + 1;
									end
									else j <= j+1;
								end
								k <= k+1;
							end
						end else begin
							valid_o <= 0;
							valid <= 1;
							busy <= 0;
							base_width <= 0;
							m <= 0;
							k <= 0;
							j <= 0;
							len <= 0;
						end
				end 
			end
		end
	end

endmodule
