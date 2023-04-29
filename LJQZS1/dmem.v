//module dmem(
//	input  [19:0] addr,
//	output reg [31:0] dataout,
//	input  [31:0] datain,
//	input  rdclk,
//	input  wrclk,
//	input [2:0] memop,
//	input we
//	/*
//	
//	output [3:0] num0,
//	output [3:0] num1,
//	output [3:0] num2,
//	output [3:0] num3,
//	output [3:0] num4,
//	output [3:0] num5
//	*/
//	);
//
//wire [31:0] block;
////reg [31:0] RAM [32767:0];
//reg [31:0] temp;
//
//assign block = addr >> 2;
//
////assign num0 = RAM[0][3:0];
////assign num1 = RAM[1][3:0];
////assign num2 = RAM[1][7:4];
////assign num3 = RAM[1][11:8];
////assign num4 = RAM[1][15:12];
////assign num5 = RAM[1][19:16];
//
//
//	//$readmemh("data.txt", RAM, 0, 7);
//	(* ram_init_file = "main_d.mif" *) reg [31:0] RAM[4095:0];
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
module dmem(
	input  [19:0] addr,
	output reg [31:0] dataout,
	input  [31:0] datain,
	input  rdclk,
	input  wrclk,
	input [2:0] memop,
	input we);

wire [3:0] byteena_a;
wire [31:0] ramq;
wire [31:0] q;
wire [31:0] din;
wire [31:0] offset;


assign byteena_a = |(memop&3'b010) ? 4'b1111 : (|(memop&3'b001) ? (addr[1:0] == 2'b00 ? 4'b0011 : 4'b1100) : (4'b0001 << addr[1:0]));
assign offset = ({30'b0, addr[1:0]} << 3);
assign q = ramq >> offset;
assign din = datain << offset;

always @(q or memop) begin
    case (memop)
        3'b000: dataout <= {{24{q[7]}}, q[7:0]};
        3'b001: dataout <= {{16{q[15]}}, q[15:0]};
        3'b010: dataout <= q;
        3'b100: dataout <= {24'b0, q[7:0]};
        3'b101: dataout <= {16'b0, q[15:0]};
        default: dataout <= 32'd0;
    endcase
end

data_mem ram_instance(byteena_a, din, addr[16:2], rdclk, addr[16:2], wrclk, we, ramq);

endmodule




