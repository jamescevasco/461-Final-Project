//------------------------------------------------------------------
// Test module.
//------------------------------------------------------------------

module processor_tb();

	//----------------------------------------------------------------
	// Internal constant and parameter definitions.
	//----------------------------------------------------------------
	parameter CLK_HALF_PERIOD = 10;
	parameter CLK_PERIOD = 2 * CLK_HALF_PERIOD;
	
	//----------------------------------------------------------------
	// Register and Wire declarations.
	//----------------------------------------------------------------
	reg tb_clk;
	reg tb_rst;
	wire [7:0] tb_dinx,tb_dinw,tb_dout;
	wire [1:0] tb_csb;
	wire tb_web;
	wire [6:0] tb_addr;
	
	//----------------------------------------------------------------
	// Device Under Test.
	//----------------------------------------------------------------
	processor proc_dut (.rst(tb_rst),
						 .clk(tb_clk),
						 .csb(tb_csb),
						 .web(tb_web),
						 .addr(tb_addr),
						 .dout(tb_dout),
						 .dinx(tb_dinx),
						 .dinw(tb_dinw));
						 
	rom_8_128_freepdk45 rom_dut (.clk0(tb_clk),
								  .csb0(tb_csb[1]),
								  .addr0(tb_addr),
								  .dout0(tb_dinw));
								 
	sram_8_64_freepdk45 ram_dut (.clk0(tb_clk),
								  .csb0(tb_csb[0]),
								  .web0(tb_web),
								  .addr0(tb_addr[5:0]),
								  .din0(tb_dout),
								  .dout0(tb_dinx));
	
	//----------------------------------------------------------------
	// clk_gen
	//
	// Always running clock generator process.
	//----------------------------------------------------------------
	always
		begin : clk_gen
			#CLK_HALF_PERIOD;
			tb_clk = !tb_clk;
		end // clk_gen
		
	//----------------------------------------------------------------
	// read_memory
	//
	// The block for loading text files.
	//----------------------------------------------------------------
	initial
		begin : read_memory
			// $readmemb("bin_memory_file.mem", memory_array, [start_address], [end_address])
			$readmemb("./data/x.txt", ram_dut.mem);
			$readmemb("./data/A.txt", rom_dut.mem);
			$readmemb("./data/C.txt", rom_dut.mem, 64);
		end 
		
	//----------------------------------------------------------------
	// save_dump
	//
	// The block for saving dump files.
	//----------------------------------------------------------------
	initial
		begin : save_dump
			$dumpfile("processor.vcd"); 
			$dumpvars(0, processor_tb); 
		end 
	
	//----------------------------------------------------------------
	// simulation
	//
	// The test vectors for the simulation.
	//----------------------------------------------------------------
	initial
		begin : simulation
			tb_rst = 0;
			tb_clk = 0;
			#60
			tb_rst = 1;
			#53850
			$finish;
		end

endmodule