module keyboard(input clk,
	input clrn,
	input ps2_clk,
	input ps2_data,
	output reg [7:0] key_count,
	output reg [7:0] cur_key,
	output [7:0] ascii_key,
	output overflow,
	output reg shift,
	output reg ctrl,
	output reg caps,
	output reg enable);

// add your definitions here

wire [7:0] keydata;
reg nextdata;
wire nextdata_n;
wire ready;
reg [2:0] stat;

reg [7:0] temp1;
reg [7:0] temp2;

//----DO NOT CHANGE BEGIN----

//scancode to ascii conversion, will be initialized by the .mif file
scancode_ram myram(cur_key, caps,  shift, ascii_key);

//PS2 interface, you may need to specify the inputs and outputs
ps2_keyboard mykey(clk, clrn, ps2_clk, ps2_data, keydata, ready, nextdata_n, overflow);
//---DO NOT CHANGE END-----

// add you code here

assign nextdata_n = nextdata;

initial begin
    key_count = 8'b0;
    cur_key = 8'b0;
    stat = 3'b0;
    nextdata = 1'b0;
	 
	 shift = 1'b0;
	 ctrl = 1'b0;
	 caps = 1'b0;
	 enable = 1'b0;
end

always @ (negedge clk) begin
    if(clrn == 0) begin
        key_count = 8'b0;
		  cur_key = 8'b0;
        stat = 3'b0;
        nextdata = 1'b0;
		  
		  shift = 1'b0;
		  ctrl = 1'b0;
		  caps = 1'b0;
		  enable = 1'b0;
		  
    end
    else if(ready) begin
        case (stat) 
            3'b000 : begin
                if((keydata == 8'h12) || (keydata == 8'h14)) begin
                    cur_key = keydata;
                    stat = 3'b011;
                    key_count = key_count + 1;
						  enable = 1'b1;
						  
						  if(keydata == 8'h12) shift = 1;
						  if(keydata == 8'h14) ctrl = 1;
                end
                else if(keydata == 8'h00) begin
						  stat = stat;
					 end
					 else begin
						  cur_key = keydata;
						  stat = 3'b001;
						  key_count = key_count + 1;
						  enable = 1;
						  if(keydata == 8'h58) caps = ~caps;
					 end
            end

            3'b001 : begin
					 if(keydata == 8'h00) begin
						  stat = stat;
					 end
                else if((keydata == 8'h12) || (keydata == 8'h14)) begin
						  temp1 = cur_key;
						  temp2 = keydata;
							
						  cur_key = keydata;
                    stat = 3'b101;
                    key_count = key_count + 1;
						  enable = 1;
						  
						  if(keydata == 8'h12) shift = 1;
						  if(keydata == 8'h14) ctrl = 1;
                end
					 else begin
						  if(keydata == 8'hF0) begin
								cur_key = 8'b0;
								stat = 3'b010;
								enable = 0;
						  end
					 end
            end

            3'b010 : begin
					 if(keydata == 8'h00) begin
						  stat = stat;
					 end
                else stat = 3'b000;
            end
				
				3'b011 : begin
				    if(keydata == 8'h00) begin
						  stat = stat;
					 end
					 else if(keydata == 8'hF0) begin
						  if(cur_key == 8'h12) shift = 0;
						  if(cur_key == 8'h14) ctrl = 0;
						  
						  cur_key = 8'b0;
						  stat = 3'b010;
						  enable = 0;
					 end
					 else if((keydata == 8'h12) || (keydata == 8'h14)) begin
						  stat = 3'b011;
					 end
					 else begin
						  temp1 = keydata;
						  temp2 = cur_key;
					 
						  cur_key = keydata;
                    stat = 3'b101;
                    key_count = key_count + 1;
						  enable = 1;
					 end
				end
				
				3'b100 : begin
				    if(keydata == 8'h00) begin
						  stat = stat;
					 end
					 else if((keydata == 8'h12) || (keydata == 8'h14)) begin
						  cur_key = temp1;
                    stat = 3'b001;
						  enable = 1;
						  
						  if(keydata == 8'h12) shift = 1'b0;
						  if(keydata == 8'h14) ctrl = 1'b0;
					 end
					 else begin
						  cur_key = temp2;
						  stat = 3'b011;
						  enable = 1'b1;
					 end
				end
				
				3'b101 : begin
				    if(keydata == 8'h00) begin
						  stat = stat;
					 end
					 else if(keydata == 8'hF0) begin
						  stat = 3'b100;
					 end
					 else begin
						  stat = 3'b101;
					 end
				end

            
				default : begin
					 stat = 3'b000;
					 key_count = 8'b0;
						 
					 cur_key = 8'b0;
			       stat = 3'b0;
					 nextdata = 1'b0;
		  
					 shift = 1'b0;
					 ctrl = 1'b0;
		 			 caps = 1'b0;
		 			 enable = 1'b0;
				end
        endcase

        nextdata = 1'b0;
    end
end

endmodule


//standard ps2 interface, you can keep this
module ps2_keyboard(clk,clrn,ps2_clk,ps2_data,data,ready,nextdata_n,overflow);
    input clk,clrn,ps2_clk,ps2_data;
	 input nextdata_n;
    output [7:0] data;
    output reg ready;
    output reg overflow;     // fifo overflow  
    // internal signal, for test
    reg [9:0] buffer;        // ps2_data bits
    reg [7:0] fifo[7:0];     // data fifo
	 reg [2:0] w_ptr,r_ptr;   // fifo write and read pointers	
    reg [3:0] count;  // count ps2_data bits
    // detect falling edge of ps2_clk
    reg [2:0] ps2_clk_sync;
    
    always @(posedge clk) begin
        ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};
    end

    wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];
    
    always @(posedge clk) begin
        if (clrn == 0) begin // reset 
            count <= 0; w_ptr <= 0; r_ptr <= 0; overflow <= 0; ready<= 0;
        end 
		else if (sampling) begin
            if (count == 4'd10) begin
                if ((buffer[0] == 0) &&  // start bit
                    (ps2_data)       &&  // stop bit
                    (^buffer[9:1])) begin      // odd  parity
                    fifo[w_ptr] <= buffer[8:1];  // kbd scan code
                    w_ptr <= w_ptr+3'b1;
                    ready <= 1'b1;
                    overflow <= overflow | (r_ptr == (w_ptr + 3'b1));
                end
                count <= 0;     // for next
            end else begin
                buffer[count] <= ps2_data;  // store ps2_data 
                count <= count + 3'b1;
            end      
        end
        if ( ready ) begin // read to output next data
				if(nextdata_n == 1'b0) //read next data
				begin
				   r_ptr <= r_ptr + 3'b1; 
					if(w_ptr==(r_ptr+1'b1)) //empty
					     ready <= 1'b0;
				end           
        end
    end

    assign data = fifo[r_ptr];
endmodule 


