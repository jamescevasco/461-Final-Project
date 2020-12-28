module mac(clk, rst, run, A, B, Y);
	input clk;
	input rst;
	input run;
	input [7:0] A, B;
	output wire [7:0] Y;
	reg [7:0] x1,x2;
	reg [15:0] product, sum;
	

	always @(posedge clk ) begin
		if (!rst) begin
			product = 0;
			x1 = 0;
			x2 = 0;
			product = 0;
		end 
		else if(run) begin
			x1 =((A[7]==0)?{1'b0,A[6:0]}:{1'b0,~(A[6:0]-1'b1)}); // Convert from Two's complement to Sign Magnitude
			x2 =((B[7]==0)?{1'b0,B[6:0]}:{1'b0,~(B[6:0]-1'b1)}); // Convert from Two's complement to Sign Magnitude
			product = (A[7]^B[7]==0)? // Decide the sign of the result
				  (
					(x2[0]? {8'b0,x1[7:0]	   }:16'b0)+
					(x2[1]? {7'b0,x1[7:0], 1'b0}:16'b0)+
					(x2[2]? {6'b0,x1[7:0], 2'b0}:16'b0)+
					(x2[3]? {5'b0,x1[7:0], 3'b0}:16'b0)+
					(x2[4]? {4'b0,x1[7:0], 4'b0}:16'b0)+
					(x2[5]? {3'b0,x1[7:0], 5'b0}:16'b0)+
					(x2[6]? {2'b0,x1[7:0], 6'b0}:16'b0)+
					(x2[7]? {1'b0,x1[7:0], 7'b0}:16'b0)
				  ):(~( // Convert the result from Sign Magnitude to the One's Complement 
					(x2[0]? {8'b0,x1[7:0]	   }:16'b0)+
					(x2[1]? {7'b0,x1[7:0], 1'b0}:16'b0)+
					(x2[2]? {6'b0,x1[7:0], 2'b0}:16'b0)+
					(x2[3]? {5'b0,x1[7:0], 3'b0}:16'b0)+
					(x2[4]? {4'b0,x1[7:0], 4'b0}:16'b0)+
					(x2[5]? {3'b0,x1[7:0], 5'b0}:16'b0)+
					(x2[6]? {2'b0,x1[7:0], 6'b0}:16'b0)+
					(x2[7]? {1'b0,x1[7:0], 7'b0}:16'b0)
				  ));
			product[15] = A[7]^B[7];
			product = product[15] ? product+1'b1 : product; // Convert the result from One's Complement to Two's Complement
		end
	end

	always @(posedge clk ) begin
		if (!rst) begin
			sum <= 0;
		end else if(run) begin
			sum <= sum + product;
		end
    end
	
	assign Y = sum [12:5]; // Due to the fixed point is between 5th and 6th.

endmodule // mac