module REG_caps_shift(
	input [7:0] addr,
	output [7:0] outdata
	
	);
	
reg [7:0] RAM_caps_shift [255:0];

initial begin
		$readmemh("caps_shift.txt", RAM_caps_shift, 0, 255);
end

assign outdata = RAM_caps_shift[addr];


endmodule
