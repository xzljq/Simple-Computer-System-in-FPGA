module REG_RAM(
	input [7:0] addr,
	output [7:0] outdata
	);
	
reg [7:0] RAM [255:0];

initial begin
		$readmemh("change.txt", RAM, 0, 255);
end

assign outdata = RAM[addr];


endmodule
