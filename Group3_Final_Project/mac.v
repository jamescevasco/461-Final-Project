module mac(clk, rst, run, A, B, Y);
	input clk;
	input rst;
	input run;
	input [15:0] A, B;
	output wire [15:0] Y;
	reg [15:0] x1,x2;
	reg [31:0] product, sum;
	

	always @(posedge clk ) begin
		if (!rst) begin
			product = 0;
			x1 = 0;
			x2 = 0;
			product = 0;
		end 
		else if(run) begin
			x1 =((A[15]==0)?{1'b0,A[14:0]}:{1'b0,~(A[14:0]-1'b1)}); // Convert from Two's complement to Sign Magnitude
			x2 =((B[15]==0)?{1'b0,B[14:0]}:{1'b0,~(B[14:0]-1'b1)}); // Convert from Two's complement to Sign Magnitude
			product = (A[15]^B[15]==0)? // Decide the sign of the result
				  (
					(x2[0]?  {16'b0,x1[15:0]	  }:32'b0)+
					(x2[1]?  {15'b0,x1[15:0], 1'b0}:32'b0)+
					(x2[2]?  {14'b0,x1[15:0], 2'b0}:32'b0)+
					(x2[3]?  {13'b0,x1[15:0], 3'b0}:32'b0)+
					(x2[4]?  {12'b0,x1[15:0], 4'b0}:32'b0)+
					(x2[5]?  {11'b0,x1[15:0], 5'b0}:32'b0)+
					(x2[6]?  {10'b0,x1[15:0], 6'b0}:32'b0)+
					(x2[7]?  {9'b0,x1[15:0],  7'b0}:32'b0)+
					(x2[8]?  {8'b0,x1[15:0],  8'b0}:32'b0)+
					(x2[9]?  {7'b0,x1[15:0],  9'b0}:32'b0)+
					(x2[10]? {6'b0,x1[15:0], 10'b0}:32'b0)+
					(x2[11]? {5'b0,x1[15:0], 11'b0}:32'b0)+
					(x2[12]? {4'b0,x1[15:0], 12'b0}:32'b0)+
					(x2[13]? {3'b0,x1[15:0], 13'b0}:32'b0)+
					(x2[14]? {2'b0,x1[15:0], 14'b0}:32'b0)+
					(x2[15]? {1'b0,x1[15:0], 15'b0}:32'b0)
				  ):(~( // Convert the result from Sign Magnitude to the One's Complement 
					(x2[0]?  {16'b0,x1[15:0]	  }:32'b0)+
					(x2[1]?  {15'b0,x1[15:0], 1'b0}:32'b0)+
					(x2[2]?  {14'b0,x1[15:0], 2'b0}:32'b0)+
					(x2[3]?  {13'b0,x1[15:0], 3'b0}:32'b0)+
					(x2[4]?  {12'b0,x1[15:0], 4'b0}:32'b0)+
					(x2[5]?  {11'b0,x1[15:0], 5'b0}:32'b0)+
					(x2[6]?  {10'b0,x1[15:0], 6'b0}:32'b0)+
					(x2[7]?  {9'b0,x1[15:0],  7'b0}:32'b0)+
					(x2[8]?  {8'b0,x1[15:0],  8'b0}:32'b0)+
					(x2[9]?  {7'b0,x1[15:0],  9'b0}:32'b0)+
					(x2[10]? {6'b0,x1[15:0], 10'b0}:32'b0)+
					(x2[11]? {5'b0,x1[15:0], 11'b0}:32'b0)+
					(x2[12]? {4'b0,x1[15:0], 12'b0}:32'b0)+
					(x2[13]? {3'b0,x1[15:0], 13'b0}:32'b0)+
					(x2[14]? {2'b0,x1[15:0], 14'b0}:32'b0)+
					(x2[15]? {1'b0,x1[15:0], 15'b0}:32'b0)
				  ));
			product[31] = A[15]^B[15];
			product = product[31] ? product+1'b1 : product; // Convert the result from One's Complement to Two's Complement
		end
	end

	always @(posedge clk ) begin
		if (!rst) begin
			sum <= 0;
		end else if(run) begin
			sum <= sum + product;
		end
    end
	
	assign Y = sum [23:8]; // Due to the fixed point is between 8th and 9th.

endmodule // mac