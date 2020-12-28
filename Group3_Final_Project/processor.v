module processor(rst,clk,csb,web,addr,dout,dinx,dinw);
	
	parameter MATRIX_WIDTH = 8;	
	input rst;
	input clk;
	input [7:0] dinx, dinw;
	output reg [1:0] csb;
	output reg web;
	output reg [6:0] addr;
	output reg [7:0] dout;
	
	reg mac_enable, mac_reset;
	reg [7:0] x_temp, w_temp, result_temp[MATRIX_WIDTH-1:0]; // The registers for intermedit results.
	reg [7:0] addr_write, addr_ram, addr_rom; // The buffers for the address
	wire [7:0] mac_output,tanh_output; // The buffers for outputs of sub-modules.
	reg [3:0] cnt_col, cnt_row, cnt_mac; // The counters.
	reg flag_calculating_D; // The flag indicating it is calculating Ax or CB'
	
	localparam	CSB_ALL = 2'b00, CSB_RAM = 2'b10, CSB_ROM = 2'b01; //States for csb signal.
	
	// Control logic: FSM
	
	// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
	// State Encoding
	// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
	localparam
		STATE_0 = 0,
		STATE_1 = 1,
		STATE_2 = 2,
		STATE_3 = 3,
		STATE_4 = 4,
		STATE_5 = 5,
		STATE_6 = 6,
		STATE_7 = 7,
		STATE_8 = 8,
		STATE_9 = 9,
		STATE_10 = 10,
		STATE_11 = 11,
		STATE_12 = 12,
		STATE_13 = 13,
		STATE_14 = 14,
		STATE_15 = 15,
		STATE_16 = 16;
	// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----

	// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
	// State reg Declarations
	// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
	reg [4:0] CurrentState ;
	reg [4:0] NextState ;
	// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----

	// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
	// Synchronous State - Transition always@ ( posedge Clock ) block
	// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
	always@ ( posedge clk ) begin
		if ( !rst ) CurrentState <= STATE_1;
		else CurrentState <= NextState ;
	end
	// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----

	
	// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
	// Conditional State - Transition always@ ( * ) block
	// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
	always@ ( * ) begin // Let the compiler to determine the sensitive signals. (Need to be careful about this).
		NextState = CurrentState ; //Using default values can greatly decrease the chance of generating latches in FSMs.
			case ( CurrentState )
				STATE_1 : NextState = STATE_2;
				STATE_2 : NextState = STATE_3;
				STATE_3 : NextState = STATE_4;
				STATE_4 : NextState = STATE_5;
				STATE_5 :
					if(cnt_mac < MATRIX_WIDTH) NextState = STATE_2;
					else NextState = STATE_6;
				STATE_6 : NextState = STATE_7;
				STATE_7 : NextState = STATE_8;
				STATE_8 : 
					if(cnt_row < MATRIX_WIDTH) NextState = STATE_2;
					else NextState =STATE_9;
				STATE_9 : 
					if(cnt_row > 0) NextState = STATE_10;
					else NextState = STATE_11;
				STATE_10 : 
					if(cnt_row > 0) NextState = STATE_9;
					else NextState = STATE_11;
				STATE_11 : NextState = STATE_12;
				STATE_12 : 
					if(flag_calculating_D) NextState = STATE_15;
					else if(cnt_col < MATRIX_WIDTH) NextState = STATE_2;
					else NextState = STATE_13;
				STATE_13 : NextState = STATE_14;
				STATE_14 : NextState = STATE_2;
				STATE_15 : 
					if(cnt_col < MATRIX_WIDTH) NextState = STATE_9;
					else NextState = STATE_16;
				STATE_16 : NextState = STATE_16;
		endcase
	end
	// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----

	
	// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
	// Outputs
	// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
	always@ ( CurrentState ) begin
		case ( CurrentState )
			STATE_1: begin //Reset state, enable RAM, disable ROM, read the address 0
				csb = CSB_RAM;
				addr_ram = 0;
				addr_rom = 0;
				addr_write = 8'b11111111; // addr_write = -1
				x_temp = 0;
				w_temp = 0;
				mac_enable = 0;
				mac_reset = 0;
				cnt_mac = 0;
				cnt_row = 0;
				cnt_col = 0;
				web = 1;
				dout = 0;
				flag_calculating_D = 0; // calculating Ax
			end
			STATE_2: begin //Read in the data of RAM, disable RAM, enable ROM, calculate the new address of RAM, disable mac.
				x_temp = dinx;
				csb = CSB_ROM;
				addr_ram = addr_ram + 1;
				mac_enable = 0;
				mac_reset = 1;
			end
			STATE_3: begin // The state for ROM to prepare data.
				
			end
			STATE_4: begin // Read in the data of ROM, disable ROM, enable RAM, calculate the new address of ROM.
				w_temp = dinw;
				csb = CSB_RAM;
				if(flag_calculating_D) addr_rom = addr_rom + 1;
				else addr_rom = addr_rom + MATRIX_WIDTH;
			end
			STATE_5: begin // The state for RAM to prepare data, enable mac, add 1 to the counter for mac.
				mac_enable = 1;
				cnt_mac = cnt_mac + 1;
			end
			
			STATE_6: begin // Finish 8 mac operations, reset x_temp and w_temp, disable mac, calculate the new addresses.
				w_temp = 0;
				x_temp = 0;
				mac_enable = 0;
				if(flag_calculating_D) begin
					addr_rom = addr_rom - MATRIX_WIDTH;
				end
				else begin
					addr_rom = addr_rom - MATRIX_WIDTH * MATRIX_WIDTH + 1;
					addr_ram = addr_ram - MATRIX_WIDTH;
				end
				cnt_mac = 0;
			end
			STATE_7: begin // Disable mac, reset mac.
				mac_reset = 0;
				mac_enable = 0;
			end
			STATE_8: begin // Read the tanh_out, finish reset mac, store intermedit results to result_temp.
				mac_reset = 1;
				result_temp[cnt_row] = tanh_output;
				cnt_row = cnt_row + 1;
			end
			STATE_9: begin // Finish the calculation of one column, reset the cnt_row, start writting back.
				web = 0;
				csb = CSB_RAM;
				addr_write = addr_write + 1;
				dout = result_temp[MATRIX_WIDTH-cnt_row];
				result_temp[MATRIX_WIDTH-cnt_row] = 0;
				cnt_row = cnt_row - 1;
			end
			STATE_10: begin // The RAM received the previous dout, update the new dout.
				addr_write = addr_write + 1;
				dout = result_temp[MATRIX_WIDTH-cnt_row];
				result_temp[MATRIX_WIDTH-cnt_row] = 0;
				cnt_row = cnt_row - 1;
			end
			STATE_11: begin // Calculate new address.
				addr_ram = addr_ram + MATRIX_WIDTH;
				addr_rom = 0;
				web = 1;
			end
			STATE_12: begin // The STATE for RAM to prepare data.
				cnt_col = cnt_col + 1;
			end
			STATE_13: begin // Set the flag for opertion, reset the addresses.
				flag_calculating_D = 1;
				addr_rom = MATRIX_WIDTH * MATRIX_WIDTH;
				cnt_col = 0;
				addr_write = 8'b11111111;
				addr_ram = 0;
			end 
			STATE_14: begin // The state for RAM to prepare data.
			end
			STATE_15: begin
				cnt_row = MATRIX_WIDTH;
			end
			STATE_16: begin // Finish
			
			end
		endcase
	end
	// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
	
	// Ouput buffer for addr.
	always@ (*) begin
		case(csb)
			CSB_RAM: begin
				if(web == 1) addr = addr_ram[6:0];
				else addr = addr_write[6:0];
			end
			CSB_ROM: addr = addr_rom[6:0];
			default: addr = 0;
		endcase
	end
		
	// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
	// Connect the MAC and TANH
	// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
	mac mac_inst(.clk(clk), .rst(mac_reset), .run(mac_enable), .A(x_temp), .B(w_temp), .Y(mac_output));
	tanh tanh_inst(.clk(clk),.rst(rst),.X(mac_output),.Y(tanh_output));
	

endmodule //processor

