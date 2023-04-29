module exp11(
	input 	clock,
	input 	reset,
	output [31:0] imemaddr,
	input  [31:0] imemdataout,
	output 	imemclk,
	output [31:0] dmemaddr,
	input  [31:0] dmemdataout,
	output [31:0] dmemdatain,
	output 	dmemrdclk,
	output	dmemwrclk,
	output [2:0] dmemop,
	output	dmemwe,
	output [31:0] dbgdata);
//add your code here

initial begin
	PC = 0;
end

//---  instr_mod  ---//
wire [6:0] op;
wire [4:0] ra, rb, rw;
wire [2:0] func3;
wire [6:0] func7;


instr_mod my_instr_mod(
	.instr (imemdataout),
	.op (op),
	.ra (ra),
	.rb (rb),
	.rw (rw),
	.func3 (func3),
	.func7 (func7)
);

//---  ctrl  ---//
wire [2:0] ExtOp;
wire RegWr, ALUAsrc;
wire [1:0] ALUBsrc;
wire [3:0] ALUctr;
wire [2:0] branch;
wire MemtoReg, MemWr;
wire [2:0] MemOp;

ctrl my_ctrl(
	.op (op),
	.func7 (func7),
	.func3 (func3),
	
	.ExtOp (ExtOp),
	.RegWr (RegWr),
	.ALUAsrc (ALUAsrc),
	.ALUBsrc (ALUBsrc),
	.ALUctr (ALUctr),
	.branch (branch),
	.MemtoReg (MemtoReg),
	.MemWr (MemWr),
	.MemOp (MemOp)
);

//--- imm_mod ---//
wire [31:0] imm;

imm_mod my_imm(
	.instr (imemdataout),
	.ExtOp (ExtOp),
	.imm (imm)
);

//--- ALU --- //
wire [31:0] dataa, datab;
wire [31:0] aluresult;
wire zero, less;

alu my_alu(
	.dataa (dataa),
	.datab (datab),
	.ALUctr (ALUctr),
	.less (less),
	.zero (zero),
	.aluresult (aluresult)
);

//--- reg ---//
wire [31:0] wrdata, outa, outb;

regfile myregfile(
	.ra (ra),
	.rb (rb),
	.rw (rw),
	.wrdata (wrdata),
	.regwr (RegWr),
	.wrclk (~clock),
	.outa (outa),
	.outb (outb)
);

//--- PC ---//
wire Asrc, Bsrc;
reg [31:0] PC;
wire [31:0] nextPC;

pc_mod my_pc(
	.pc (PC),
	.imm (imm),
	.bus (outa),
	.Asrc (Asrc),
	.Bsrc (Bsrc),
	.next (nextPC)
);

//--- branch ---//
Branch_mod my_branch(
	.branch (branch),
	.less (less),
	.zero (zero),
	.Asrc (Asrc),
	.Bsrc (Bsrc)
);

assign dataa = (ALUAsrc == 1'b0)? outa : PC ;
assign datab = (ALUBsrc == 2'b00)? outb : ((ALUBsrc == 2'b01)? imm : 32'h0000_0004) ;
assign wrdata = (MemtoReg == 1'b0)? aluresult : dmemdataout ;
assign dbgdata = PC;
assign imemclk = ~clock;
assign imemaddr = reset ? 0 : nextPC;
assign dmemop = MemOp;
assign dmemwe = MemWr;
assign dmemrdclk = clock;
assign dmemwrclk = ~clock;
assign dmemaddr = aluresult;
assign dmemdatain = outb;

always @ (negedge clock) begin
	if(reset) PC <= 32'b0;
	else PC <= nextPC;
end

endmodule


module instr_mod(
	input [31:0] instr,
	output [6:0] op,
	output [4:0] ra,
	output [4:0] rb,
	output [4:0] rw,
	output [2:0] func3,
	output [6:0] func7
);

assign op = instr[6:0];
assign ra = instr[19:15];
assign rb = instr[24:20];
assign rw = instr[11:7];
assign func3 = instr[14:12];
assign func7 = instr[31:25];

endmodule


module ctrl(
	input [6:0] op,
	input [6:0] func7,
	input [2:0] func3,
	
	output reg [2:0] ExtOp,
	output reg RegWr,
	output reg ALUAsrc,
	output reg [1:0] ALUBsrc,
	output reg [3:0] ALUctr,
	output reg [2:0] branch,
	output reg MemtoReg,
	output reg MemWr,
	output reg [2:0] MemOp
);


always @ (*) begin
	if(op[6:2] == 5'b11000) ExtOp = 3'b011;
	else if(op[4]&op[2]) ExtOp = 3'b001;
	else if(op[6:2] == 5'b01000) ExtOp = 3'b010;
	else if(op[6:2] == 5'b11011) ExtOp = 3'b100;
	else ExtOp = 3'b000;
end


always @ (*) begin
	if(op[6:2] == 5'b11000 ) RegWr = 1'b0;
	else if(op[6:2] == 5'b01000) RegWr = 1'b0;
	else RegWr = 1'b1;
end


always @ (*) begin
	if(op[6:2] == 5'b11000) begin
		case (func3)
			3'b000 : branch = 3'b100;
			3'b001 : branch = 3'b101;
			3'b100 : branch = 3'b110;
			3'b101 : branch = 3'b111;
			3'b110 : branch = 3'b110;
			3'b111 : branch = 3'b111;
			default : branch = 3'b000;
		endcase
	end
	else if(op[6:2] == 5'b11011) branch = 3'b001;
	else if(op[6:2] == 5'b11001) branch = 3'b010;
	else branch = 3'b000;
end


always @ (*) begin
	if(op[4]|op[3]|op[2]) MemtoReg = 1'b0;
	else MemtoReg = 1'b1;
end


always @ (*) begin
	if(op[6:2] == 5'b01000) MemWr = 1'b1;
	else MemWr = 1'b0;
end


always @ (*) begin
	MemOp = func3;
end


always @ (*) begin
	case (op[6:2])
		5'b00101 : ALUAsrc = 1'b1;
		5'b11011 : ALUAsrc = 1'b1;
		5'b11001 : ALUAsrc = 1'b1;
		default : ALUAsrc = 1'b0;
	endcase
end


always @ (*) begin
	case (op[6:2]) 
		5'b01101 : ALUBsrc = 2'b01;
		5'b00101 : ALUBsrc = 2'b01;
		5'b00100 : ALUBsrc = 2'b01;
		
		5'b01100 : ALUBsrc = 2'b00;
		5'b11000 : ALUBsrc = 2'b00;
		
		5'b11011 : ALUBsrc = 2'b10;
		5'b11001 : ALUBsrc = 2'b10;
		
		5'b00000 : ALUBsrc = 2'b01;
		5'b01000 : ALUBsrc = 2'b01;
		default : ALUBsrc = 2'b00;
	endcase
end


always @ (*) begin
	casex({op[6:2],func3,func7[5]})
		9'b01101xxxx : ALUctr = 4'b0011; 
		9'b00101xxxx : ALUctr = 4'b0000; 
		9'b00100000x : ALUctr = 4'b0000; 
		9'b00100010x : ALUctr = 4'b0010; 
		9'b00100011x : ALUctr = 4'b1010; 
		9'b00100100x : ALUctr = 4'b0100; 
		9'b00100110x : ALUctr = 4'b0110; 
		9'b00100111x : ALUctr = 4'b0111; 
		9'b001000010 : ALUctr = 4'b0001; 
		9'b001001010 : ALUctr = 4'b0101; 
		9'b001001011 : ALUctr = 4'b1101; 
		9'b011000000 : ALUctr = 4'b0000; 
		9'b011000001 : ALUctr = 4'b1000; 
		9'b011000010 : ALUctr = 4'b0001; 
		9'b011000100 : ALUctr = 4'b0010; 
		9'b011000110 : ALUctr = 4'b1010; 
		9'b011001000 : ALUctr = 4'b0100; 
		9'b011001010 : ALUctr = 4'b0101; 
		9'b011001011 : ALUctr = 4'b1101; 
		9'b011001100 : ALUctr = 4'b0110; 
		9'b011001110 : ALUctr = 4'b0111; 
		9'b11011xxxx : ALUctr = 4'b0000; 
		9'b11001000x : ALUctr = 4'b0000; 
		9'b11000000x : ALUctr = 4'b0010; 
		9'b11000001x : ALUctr = 4'b0010; 
		9'b11000100x : ALUctr = 4'b0010; 
		9'b11000101x : ALUctr = 4'b0010; 
		9'b11000110x : ALUctr = 4'b1010; 
		9'b11000111x : ALUctr = 4'b1010; 
		9'b00000000x : ALUctr = 4'b0000; 
		9'b00000001x : ALUctr = 4'b0000; 
		9'b00000010x : ALUctr = 4'b0000; 
		9'b00000100x : ALUctr = 4'b0000; 
		9'b00000101x : ALUctr = 4'b0000; 
		9'b01000000x : ALUctr = 4'b0000; 
		9'b01000001x : ALUctr = 4'b0000; 
		9'b01000010x : ALUctr = 4'b0000;
		default : ALUctr = 4'b0000;
	endcase
end

endmodule


module imm_mod(
	input [31:0] instr,
	input [2:0] ExtOp,
	output reg [31:0] imm
);

wire [31:0] immI, immU, immS, immB, immJ;

assign immI = {{20{instr[31]}},instr[31:20]};
assign immU = {instr[31:12],12'b0};
assign immS = {{20{instr[31]}}, instr[31:25], instr[11:7]};
assign immB = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
assign immJ = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

always @ (*) begin
	case (ExtOp)
		3'b000 : imm = immI;
		3'b001 : imm = immU;
		3'b010 : imm = immS;
		3'b011 : imm = immB;
		3'b100 : imm = immJ;
		default : imm = 32'b0;
	endcase
end

endmodule


module alu(
	input [31:0] dataa,
	input [31:0] datab,
	input [3:0]  ALUctr,
	output reg less,
	output reg zero,
	output reg [31:0] aluresult
);

reg [31:0] temp;
reg F;
reg [31:0] res;
wire [31:0] shift;

barrel shift_reg (dataa, datab[4:0], ~ALUctr[2], ALUctr[3], shift);

always @ (*) begin
	casez (ALUctr)
		4'b0000 : begin
			aluresult = dataa + datab;
			zero = ~(|aluresult);
		end

		4'b1000 : begin
			temp = ~datab;
			aluresult = dataa + temp + 1;
			zero = ~(|aluresult);
		end

		4'bz001 : begin
			aluresult = shift;
			zero = ~(|aluresult);
		end

		4'b0010 : begin
			temp = ~datab;
			res = dataa + temp + 1;
			if(dataa[31]^datab[31]) less = dataa[31];
			else less = res[31];
			aluresult = {31'b0, less};

			zero = (dataa == datab);
		end

		4'b1010 : begin
			temp = ~datab;
			{F,res} = dataa + temp + 1;
			less = ~F;
			aluresult = {31'b0, less};

			zero = (dataa == datab);
		end

		4'bz011 : begin
			aluresult = datab;
			zero = ~(|aluresult);
		end

		4'bz100 : begin
			aluresult = dataa ^ datab;
			zero = ~(|aluresult);
		end

		4'bz101 : begin
			aluresult = shift;
			zero = ~(|aluresult);
		end

		4'bz110 : begin
			aluresult = dataa | datab;
			zero = ~(|aluresult);
		end

		4'bz111 : begin
			aluresult = dataa & datab;
			zero = ~(|aluresult);
		end
	endcase
end

endmodule



module barrel(input [31:0] indata,
			  input [4:0] shamt,
			  input lr,
			  input al,
			  output reg [31:0] outdata);

//add your code here

reg [31:0] temp;

always @ (*) begin
	case ({lr,al}) 
		2'b00 : begin
			temp = shamt[0]? {1'b0,indata[31:1]} : indata;
			temp = shamt[1]? {2'b0,temp[31:2]} : temp;
			temp = shamt[2]? {4'b0,temp[31:4]} : temp;
			temp = shamt[3]? {8'b0,temp[31:8]} : temp;
			temp = shamt[4]? {16'b0,temp[31:16]} : temp;
		end

		2'b01 : begin
			temp = shamt[0]? {indata[31],indata[31:1]} : indata;
			temp = shamt[1]? { {2{indata[31]}} ,temp[31:2]} : temp;
			temp = shamt[2]? { {4{indata[31]}} ,temp[31:4]} : temp;
			temp = shamt[3]? { {8{indata[31]}} ,temp[31:8]} : temp;
			temp = shamt[4]? { {16{indata[31]}} ,temp[31:16]} : temp;
		end

		default : begin
			temp = shamt[0]? {indata[30:0],1'b0} : indata;
			temp = shamt[1]? {temp[29:0],2'b0} : temp;
			temp = shamt[2]? {temp[27:0],4'b0} : temp;
			temp = shamt[3]? {temp[23:0],8'b0} : temp;
			temp = shamt[4]? {temp[15:0],16'b0} : temp;
		end
	endcase

	outdata = temp;
end

endmodule


module pc_mod(
	input [31:0] pc,
	input [31:0] imm,
	input [31:0] bus,
	input Asrc,
	input Bsrc,
	output [31:0] next
);

wire [31:0] A,B;
assign A = (Asrc)? imm : 32'h0000_0004;
assign B = (Bsrc)? bus : pc;
assign next = A + B;

endmodule 


module regfile(
	input  [4:0]  ra,
	input  [4:0]  rb,
	input  [4:0]  rw,
	input  [31:0] wrdata,
	input  regwr,
	input  wrclk,
	output [31:0] outa,
	output [31:0] outb
);
	
	initial begin
		regs[0] = 0;
	end

	reg [31:0] regs[31:0];	
	
	assign outa = regs[ra];
	assign outb = regs[rb];
	
	always @ (posedge wrclk) begin
		if( (regwr == 1) && (rw != 0) ) begin
			regs[rw] <= wrdata;
		end
	end
endmodule


module Branch_mod (
	input [2:0] branch,
	input less,
	input zero,
	output reg Asrc,
	output reg Bsrc
);

always @ (*) begin
	case (branch) 
		3'b000 : begin Asrc = 1'b0; Bsrc = 1'b0; end
		3'b001 : begin Asrc = 1'b1; Bsrc = 1'b0; end
		3'b010 : begin Asrc = 1'b1; Bsrc = 1'b1; end
		3'b100 : begin Asrc = zero; Bsrc = 1'b0; end
		3'b101 : begin Asrc = ~zero; Bsrc = 1'b0; end
		3'b110 : begin Asrc = less; Bsrc = 1'b0; end
		3'b111 : begin Asrc = ~less; Bsrc = 1'b0; end
		default : begin Asrc = 1'b0; Bsrc = 1'b0; end
	endcase
end

endmodule
