module lcd1602_wr_cmd(
	input     wire          clk,   //50MHz
	input     wire          rst_n,
										       
	input     wire  	       wr_cmd_en,
	input     wire  [7:0]   wr_cmd,
	output    wire          wr_cmd_done,
	
	output    reg   [7:0]   cmd_q,
	output    wire          cmd_rs,
	output    reg           cmd_en
);
	parameter    T_2ms  =  100_000;
	reg    [7:0]   wr_cmd_temp;
	reg    [16:0]  cnt;
	assign cmd_rs = 1'b0;
	always@(posedge clk)begin
		if(!rst_n)
			wr_cmd_temp <=8'd0;
		else if(wr_cmd_en)
			wr_cmd_temp<=wr_cmd;
		else if(wr_cmd_done)
			wr_cmd_temp <=8'd0;
		else
			wr_cmd_temp<=wr_cmd_temp;
	end
	always@(posedge clk)begin
		if(!rst_n)
			cnt<=17'd0;
		else if(wr_cmd_en==1'b1)
			cnt<=17'd1;
		else if(0<cnt && cnt<T_2ms-1'b1)
			cnt<=cnt+1'b1;
		else
			cnt<=17'd0;
	end
	always@(posedge clk)begin
		if(!rst_n)
			begin cmd_q<=8'd0;cmd_en<=1'b0;end
		else case(cnt)
			17'd0              : begin cmd_q<=8'd0;cmd_en<=1'b0;end
			17'd9              : begin cmd_q<=wr_cmd_temp;cmd_en<=1'b0;end
			(T_2ms/4)-1'b1     : begin cmd_q<=wr_cmd_temp;cmd_en<=1'b1;end
			(3*(T_2ms/4))-1'b1 : begin cmd_q<=wr_cmd_temp;cmd_en<=1'b0;end
			T_2ms-1'b1     : begin cmd_q<=8'd0;cmd_en<=1'b0;end
			default : begin cmd_q<=cmd_q;cmd_en<=cmd_en;end
		endcase
	end
	
	assign wr_cmd_done = (cnt==T_2ms-1'b1)?1'b1:1'b0;
endmodule