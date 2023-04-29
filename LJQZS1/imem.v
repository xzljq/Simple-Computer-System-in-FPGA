//module imem(
//	input  [31:0] addr,
//	output reg [31:0] dataout,//revise the type of dataout
//	input  [31:0] datain,
//	input  rdclk,
//	input  wrclk,
//	input [2:0] memop,
//	input we
//	);
//	
///*
////instr_mem (data,rdaddress,	rdclock,	wraddress,	wrclock,	wren,	q);
//
//
//instr_mem my_instr_mem(datain, addr, rdclk, addr, wrclk, we, dataout);
//endmodule
//*/
//
//wire [31:0] block;
////reg [31:0] RAM [65535:0];
//reg [31:0] temp;
//
//assign block = addr >> 2;
//
//
////$readmemh("instr.txt", RAM, 0, 1023);
//(* ram_init_file = "main.mif" *) reg [31:0] RAM[4095:0];
//
//
//always @ (posedge wrclk) begin
//	if(we) begin
//		case(memop)
//			3'b000 : begin
//				case(addr[1:0])
//					2'b00 : RAM[block][7:0] <= datain[7:0];
//					2'b01 : RAM[block][15:8] <= datain[7:0];
//					2'b10 : RAM[block][23:16] <= datain[7:0];
//					2'b11 : RAM[block][31:24] <= datain[7:0];
//				endcase
//			end
//
//			3'b001 : begin
//				if(addr[1]) RAM[block][31:16] <= datain[15:0];
//				else RAM[block][15:0] <= datain[15:0];
//			end
//
//			3'b010 : begin
//				RAM[block] <= datain;
//			end
//		endcase
//	end
//end
//
//
//always @ (posedge rdclk) begin
//	case (memop)
//		3'b000 : begin
//			case (addr[1:0])
//				2'b00 : temp = RAM[block][7:0];
//				2'b01 : temp = RAM[block][15:8];
//				2'b10 : temp = RAM[block][23:16];
//				2'b11 : temp = RAM[block][31:24];
//			endcase
//			dataout = {{24{temp[7]}},  temp[7:0]};
//		end
//
//		3'b001 : begin
//			if(addr[1]) temp = RAM[block][31:16];
//			else temp = RAM[block][15:0];
//			dataout = {{16{temp[15]}},  temp[15:0]};
//		end
//
//		3'b010 : begin
//			dataout = RAM[block];
//		end
//
//		3'b100 : begin
//			case (addr[1:0])
//				2'b00 : dataout <= RAM[block][7:0];
//				2'b01 : dataout <= RAM[block][15:8];
//				2'b10 : dataout <= RAM[block][23:16];
//				2'b11 : dataout <= RAM[block][31:24];
//			endcase
//		end
//
//		3'b101 : begin
//			if(addr[1]) dataout <= RAM[block][31:16];
//			else dataout <= RAM[block][15:0];
//		end
//	endcase
//end
//
//endmodule

module imem(
	input  [31:0] addr,
	output [31:0] dataout,//revise the type of dataout
	input  [31:0] datain,
	input  rdclk,
	input  wrclk,
	input [2:0] memop,
	input we
	);


	instr_mem imem_instance(addr >> 2, rdclk, dataout);

endmodule


