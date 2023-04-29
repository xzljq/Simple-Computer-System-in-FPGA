module REG_caps(
	input [7:0] addr,
	output [7:0] outdata
	
	);
	
reg [7:0] RAM_caps [255:0];

initial begin
		$readmemh("caps.txt", RAM_caps, 0, 255);
end

assign outdata = RAM_caps[addr];

endmodule
