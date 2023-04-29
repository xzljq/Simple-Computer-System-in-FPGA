module REG_shift(
	input [7:0] addr,
	output [7:0] outdata
	
	);
	
reg [7:0] RAM_shift [255:0];

initial begin
		$readmemh("shift.txt", RAM_shift, 0, 255);
end

assign outdata = RAM_shift[addr];

endmodule
