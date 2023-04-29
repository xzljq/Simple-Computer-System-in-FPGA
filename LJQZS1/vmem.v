module vmem(
	input  [19:0] wraddr,
	input  [9:0] rdline,
	input  [9:0] rdcol,
	output [7:0] dataout,
	input  [7:0] datain,
	input  wrclk,
	input we
	);
	
reg [7:0] RAM [3839:0];
reg [7:0] zero_line;
wire [11:0] now_line;
wire [11:0] act_line;

assign act_line  = rdline >> 4;

assign now_line = (act_line + zero_line)%30;

assign dataout = RAM[(now_line<<7) + (rdcol/9)];
	
initial begin
	zero_line = 8'b0;
end	

always @ (posedge wrclk) begin
	if(we) begin
		if(wraddr == 20'b0) zero_line <= datain;
		else RAM[wraddr - 20'h4] <= datain;
	end
end



endmodule

