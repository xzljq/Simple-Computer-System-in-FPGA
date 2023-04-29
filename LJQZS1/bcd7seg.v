module bcd7seg(
	 input  enable,
	 input  [7:0] b,
	 output reg [6:0] h
	 );

always @ (b)
begin
if(enable) begin
	case (b[3:0])
		4'b0000 : h = 7'b1000000;
		4'b0001 : h = 7'b1111001;
		4'b0010 : h = 7'b0100100;
		4'b0011 : h = 7'b0110000;
		4'b0100 : h = 7'b0011001;
		4'b0101 : h = 7'b0010010;
		4'b0110 : h = 7'b0000010;
		4'b0111 : h = 7'b1111000;
		4'b1000 : h = 7'b0000000;
		4'b1001 : h = 7'b0010000;
		4'b1010 : h = 7'b0001000;
		4'b1011 : h = 7'b0000011;
		4'b1100 : h = 7'b1000110;
		4'b1101 : h = 7'b0100001;
		4'b1110 : h = 7'b0000110;
		4'b1111 : h = 7'b0001110;
	endcase
end
else h = 7'b1111111;
end
	 
endmodule