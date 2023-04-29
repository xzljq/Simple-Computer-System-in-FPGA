module scancode_ram(addr, caps, shift, outdata);
input [7:0] addr;
input caps;
input shift;
output reg [7:0] outdata;


wire [7:0] data0;
wire [7:0] data1;
wire [7:0] data2;
wire [7:0] data3;

REG_RAM 	my_RAM(addr, data0);
REG_shift 	my_shift(addr, data1);
REG_caps 	my_caps(addr, data2);
REG_caps_shift 	my_caps_shift(addr, data3);

always @(addr, caps, shift)
begin
		case({caps,shift})
			2'b00 : outdata = data0;
			2'b01 : outdata = data1;
			2'b10 : outdata = data2;
			2'b11 : outdata = data3;
			default : outdata = 8'h0;
		endcase
end

endmodule
