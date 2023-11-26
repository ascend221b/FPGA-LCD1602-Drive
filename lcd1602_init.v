module lcd1602_init(
	input     wire        clk,  //50MHz
	input     wire        rst_n,
	
	input     wire        init_en,
	output    reg         init_done,
	
	output    reg         init_cmd_en,
	output    reg  [7:0]  init_cmd,
	input     wire        init_cmd_done
);
	localparam       T_5ms      =  250_000;
	localparam       State_Idle =  13'b0_0000_0000_0001;
	localparam       Stite_S0   =  13'b0_0000_0000_0010;//写指令38；
	localparam       Stite_S1   =  13'b0_0000_0000_0100;//延时5ms；
	localparam       Stite_S2   =  13'b0_0000_0000_1000;//写指令38；
	localparam       Stite_S3   =  13'b0_0000_0001_0000;//延时5ms；
	localparam       Stite_S4   =  13'b0_0000_0010_0000;//写指令38；
	localparam       Stite_S5   =  13'b0_0000_0100_0000;//延时5ms；
	localparam       Stite_S6   =  13'b0_0000_1000_0000;//写指令38；
	localparam       Stite_S7   =  13'b0_0001_0000_0000;//写指令08；
	localparam       Stite_S8   =  13'b0_0010_0000_0000;//写指令01；
	localparam       Stite_S9   =  13'b0_0100_0000_0000;//写指令06；
  localparam       Stite_S10  =  13'b0_1000_0000_0000;//写指令0c；
	localparam       Stite_End  =  13'b1_0000_0000_0000;
	
	reg  [12:0]  c_state;
	reg  [12:0]  n_state;
	reg  [17:0]   cnt1;
	reg  [17:0]   cnt2;
	reg  [17:0]   cnt3;
	
	always@(posedge clk)begin
		if(!rst_n)
			c_state<=13'd0;
		else
			c_state<=n_state;
	end
	always@(*)begin
		case(c_state)
			State_Idle : n_state = (init_en==1'b1) ? Stite_S0 : State_Idle;
			Stite_S0   : n_state = (init_cmd_done==1'b1) ? Stite_S1 : Stite_S0;
			Stite_S1   : n_state = (cnt1==T_5ms-1) ? Stite_S2 : Stite_S1;
			Stite_S2   : n_state = (init_cmd_done==1'b1) ? Stite_S3 : Stite_S2;
			Stite_S3   : n_state = (cnt2==T_5ms-1) ? Stite_S4 : Stite_S3;
			Stite_S4   : n_state = (init_cmd_done==1'b1) ? Stite_S5 : Stite_S4;
			Stite_S5   : n_state = (cnt3==T_5ms-1) ? Stite_S6 : Stite_S5;
			Stite_S6   : n_state = (init_cmd_done==1'b1) ? Stite_S7 : Stite_S6;
			Stite_S7   : n_state = (init_cmd_done==1'b1) ? Stite_S8 : Stite_S7;
			Stite_S8   : n_state = (init_cmd_done==1'b1) ? Stite_S9 : Stite_S8;
			Stite_S9   : n_state = (init_cmd_done==1'b1) ? Stite_S10 : Stite_S9;
			Stite_S10  : n_state = (init_cmd_done==1'b1) ? Stite_End : Stite_S10;
		  Stite_End  : n_state = State_Idle;
			default   : n_state = State_Idle;
		endcase
	end
	
	always@(posedge clk)begin
		if(!rst_n)
			cnt1<=18'd0;
		else if(c_state==Stite_S1)
			if(cnt1<T_5ms-1)
				cnt1<=cnt1+1'b1;
			else
				cnt1<=18'd0;
		else
			cnt1<=18'd0;
	end
	always@(posedge clk)begin
		if(!rst_n)
			cnt2<=18'd0;
		else if(c_state==Stite_S3)
			if(cnt2<T_5ms-1)
				cnt2<=cnt2+1'b1;
			else
				cnt2<=18'd0;
		else
			cnt2<=18'd0;
	end
	always@(posedge clk)begin
		if(!rst_n)
			cnt3<=18'd0;
		else if(c_state==Stite_S5)
			if(cnt3<T_5ms-1)
				cnt3<=cnt3+1'b1;
			else
				cnt3<=18'd0;
		else
			cnt3<=18'd0;
	end
	
	always@(posedge clk)begin
		if(!rst_n)
			init_cmd_en<=1'b0;
		else case(c_state)
			State_Idle : if(init_en==1'b1) init_cmd_en<=1'b1; else init_cmd_en<=1'b0;
			Stite_S0   : init_cmd_en<=1'b0;
			Stite_S1   : if(cnt1==T_5ms-1) init_cmd_en<=1'b1; else init_cmd_en<=1'b0;
			Stite_S2   : init_cmd_en<=1'b0;
			Stite_S3   : if(cnt2==T_5ms-1) init_cmd_en<=1'b1; else init_cmd_en<=1'b0;
			Stite_S4   : init_cmd_en<=1'b0;
			Stite_S5   : if(cnt3==T_5ms-1) init_cmd_en<=1'b1; else init_cmd_en<=1'b0;
			Stite_S6   : if(init_cmd_done==1'b1) init_cmd_en<=1'b1; else init_cmd_en<=1'b0;
			Stite_S7   : if(init_cmd_done==1'b1) init_cmd_en<=1'b1; else init_cmd_en<=1'b0;
			Stite_S8   : if(init_cmd_done==1'b1) init_cmd_en<=1'b1; else init_cmd_en<=1'b0;
			Stite_S9   : if(init_cmd_done==1'b1) init_cmd_en<=1'b1; else init_cmd_en<=1'b0;
			Stite_S10  : init_cmd_en<=1'b0;
		  Stite_End  : init_cmd_en<=1'b0;
			default   : init_cmd_en<=1'b0;
		endcase
	end
	always@(posedge clk)begin
		if(!rst_n)
			init_cmd<=8'd0;
		else case(c_state)
			State_Idle : if(init_en==1'b1) init_cmd<=8'h38; else init_cmd<=8'd0;
			Stite_S0   : init_cmd<=8'd0;
			Stite_S1   : if(cnt1==T_5ms-1) init_cmd<=8'h38; else init_cmd<=8'd0;
			Stite_S2   : init_cmd<=8'd0;
			Stite_S3   : if(cnt2==T_5ms-1) init_cmd<=8'h38; else init_cmd<=8'd0;
			Stite_S4   : init_cmd<=8'd0;
			Stite_S5   : if(cnt3==T_5ms-1) init_cmd<=8'h38; else init_cmd<=8'd0;
			Stite_S6   : if(init_cmd_done==1'b1) init_cmd<=8'h08; else init_cmd<=8'd0;
			Stite_S7   : if(init_cmd_done==1'b1) init_cmd<=8'h01; else init_cmd<=8'd0;
			Stite_S8   : if(init_cmd_done==1'b1) init_cmd<=8'h06; else init_cmd<=8'd0;
			Stite_S9   : if(init_cmd_done==1'b1) init_cmd<=8'h0c; else init_cmd<=8'd0;
			Stite_S10  : init_cmd<=8'd0;
		  Stite_End  : init_cmd<=8'd0;
			default   : init_cmd<=8'd0;
		endcase
	end
	always@(posedge clk)begin
		if(!rst_n)
			init_done<=1'b0;
		else if(c_state==Stite_End)
			init_done<=1'b1;
		else
			init_done<=1'b0;
	end
endmodule