module lcd1602_wr_data(
	input     wire          clk,   //50MHz
	input     wire          rst_n,
										       
	input     wire  	       wr_data_en,
	input     wire  [7:0]   wr_data,
	output    wire          wr_data_done,
	
	output    reg   [7:0]   data_q,
	output    wire          data_rs,
	output    reg           data_en
);
	parameter    T_2ms  =  100_000;
	reg    [7:0]   wr_data_temp;
	reg    [16:0]  cnt;
	assign data_rs = 1'b1;
	always@(posedge clk)begin
		if(!rst_n)
			wr_data_temp <=8'd0;
		else if(wr_data_en)
			wr_data_temp<=wr_data;
		else if(wr_data_done)
			wr_data_temp <=8'd0;
		else
			wr_data_temp<=wr_data_temp;
	end
	always@(posedge clk)begin
		if(!rst_n)
			cnt<=17'd0;
		else if(wr_data_en==1'b1)
			cnt<=17'd1;
		else if(0<cnt && cnt<T_2ms-1'b1)
			cnt<=cnt+1'b1;
		else
			cnt<=17'd0;
	end
	always@(posedge clk)begin
		if(!rst_n)
			begin data_q<=8'd0;data_en<=1'b0;end
		else case(cnt)
			17'd0              : begin data_q<=8'd0;data_en<=1'b0;end
			17'd9              : begin data_q<=wr_data_temp;data_en<=1'b0;end
			(T_2ms/4)-1'b1     : begin data_q<=wr_data_temp;data_en<=1'b1;end
			(3*(T_2ms/4))-1'b1 : begin data_q<=wr_data_temp;data_en<=1'b0;end
			T_2ms-1'b1     : begin data_q<=8'd0;data_en<=1'b0;end
			default : begin data_q<=data_q;data_en<=data_en;end
		endcase
	end
	
	assign wr_data_done = (cnt==T_2ms-1'b1)?1'b1:1'b0;
endmodule