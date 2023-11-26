module lcd1602_drive(
	input    wire     			  clk, //50MHz
	input    wire     			  rst_n,
													  
	input    wire     			  user_show_flag,  //显示命令，一个时钟周期
	input    wire     [15:0] user_addr_data,  // 8cmd + 8data
	output   reg             user_ready,      //lcd1602初始化结束后置1
	output   reg             show_done,       //显示完成
	
	output   reg      [7:0]  q_out,
	output   reg             rs_out,
	output   reg             en_out,
	output   wire            rw_out
);
	localparam    State_Idle      =  6'b00_0001;
	localparam    State_init      =  6'b00_0010;
	localparam    State_wait_init =  6'b00_0100;
	localparam    State_Wait_work =  6'b00_1000;
	localparam    State_Work_cmd  =  6'b01_0000;
	localparam    State_Work_data =  6'b10_0000;
	reg   [15:0] user_addr_data_r;
	reg   [5:0]  c_state;
	reg   [5:0]  n_state;
	
	reg   	       wr_cmd_en;
	reg   [7:0]    wr_cmd;
	wire           wr_cmd_done;
	wire  [7:0]   cmd_q;
	wire          cmd_rs;
	wire          cmd_en;
	
	reg   	       wr_data_en;//
	reg   [7:0]    wr_data;//
	wire           wr_data_done;
	wire  [7:0]   data_q;
	wire          data_rs;
	wire          data_en;
	
	reg           init_en;  
	wire          init_done;
	wire          init_cmd_en;
	wire   [7:0]  init_cmd;
	wire          init_cmd_done;
	
	wire   [7:0]  init_out_q; 
	wire          init_out_rs;
	wire          init_out_en;
	lcd1602_init lcd1602_init_inst(
	.clk                (clk          ),  //50MHz
	.rst_n              (rst_n        ),

	.init_en            (init_en      ),
	.init_done          (init_done    ),

	.init_cmd_en        (init_cmd_en  ),
	.init_cmd           (init_cmd     ),
	.init_cmd_done      (init_cmd_done)
);
	lcd1602_wr_cmd lcd1602_wr_cmd_inst(
		.clk            (clk        ),   //50MHz
		.rst_n          (rst_n      ),

		.wr_cmd_en      (wr_cmd_en  ),
		.wr_cmd         (wr_cmd     ),
		.wr_cmd_done    (wr_cmd_done),

		.cmd_q          (cmd_q      ),
		.cmd_rs         (cmd_rs     ),
		.cmd_en         (cmd_en     )
	);
	lcd1602_wr_cmd lcd1602_wr_cmd_inst2(
		.clk            (clk        ),   //50MHz
		.rst_n          (rst_n      ),

		.wr_cmd_en      (init_cmd_en  ),
		.wr_cmd         (init_cmd     ),
		.wr_cmd_done    (init_cmd_done),

		.cmd_q          (init_out_q      ),
		.cmd_rs         (init_out_rs     ),
		.cmd_en         (init_out_en     )
	);
	lcd1602_wr_data lcd1602_wr_data_inst(
		.clk            (clk        ),   //50MHz
		.rst_n          (rst_n      ),

		.wr_data_en      (wr_data_en  ),
		.wr_data         (wr_data     ),
		.wr_data_done    (wr_data_done),

		.data_q          (data_q      ),
		.data_rs         (data_rs     ),
		.data_en         (data_en     )
	);
	always@(posedge clk)begin
		if(!rst_n)
			user_addr_data_r<=16'd0;
		else if(user_show_flag)
			user_addr_data_r<=user_addr_data;
		else if(show_done)
			user_addr_data_r<=16'd0;
		else
			user_addr_data_r<=user_addr_data_r;
	end
	assign rw_out = 1'b0;
	always@(posedge clk)begin
		if(!rst_n)
			c_state<=State_Idle;
		else 
			c_state<=n_state;
	end
	always@(*)begin
		case(c_state)
			State_Idle      : n_state = State_init;  
			State_init      : n_state = State_wait_init;
			State_wait_init : n_state = (init_done==1'b1) ? State_Wait_work : State_wait_init;
			State_Wait_work : n_state = (user_show_flag==1'b1) ? State_Work_cmd : State_Wait_work;
			State_Work_cmd  : n_state = (wr_cmd_done==1'b1) ? State_Work_data : State_Work_cmd;
			State_Work_data : n_state = (wr_data_done==1'b1) ? State_wait_init : State_Work_data;
			default : n_state = State_Wait_work;
		endcase
	end
	always@(posedge clk)begin
		if(!rst_n)
			user_ready<=1'b0;
		else if(c_state==State_Idle)
			user_ready<=1'b0;
		else if(c_state==State_Wait_work)
			user_ready<=1'b1;
		else
			user_ready<=user_ready;
	end
	
	always@(posedge clk)begin
		if(!rst_n)
			show_done<=1'b0;
		else if(c_state==State_Work_data && wr_data_done==1'b1)
			show_done<=1'b1;
		else
			show_done<=1'b0;
	end
	always@(posedge clk)begin
		if(!rst_n)
			init_en<=1'b0;
		else if(c_state==State_init)
			init_en<=1'b1;
		else
			init_en<=1'b0;
	end
	always@(posedge clk)begin
		if(!rst_n)
			begin wr_cmd_en<=1'b0; wr_cmd<=8'd0;end
		else if(c_state==State_Wait_work && user_show_flag==1'b1)
			begin wr_cmd_en<=1'b1; wr_cmd<=user_addr_data[15:8];end
		else
			begin wr_cmd_en<=1'b0; wr_cmd<=8'd0;end
	end
	
	always@(posedge clk)begin
		if(!rst_n)
			begin wr_data_en<=1'b0; wr_data<=8'd0;end
		else if(c_state==State_Work_cmd && wr_cmd_done==1'b1)
			begin wr_data_en<=1'b1; wr_data<=user_addr_data_r[7:0];end
		else
			begin wr_data_en<=1'b0; wr_data<=8'd0;end
	end
	
	always@(posedge clk)begin
		if(!rst_n)
			begin q_out<=8'd0;rs_out<=1'b0;en_out<=1'b0;end
		else case(c_state)
			State_Idle      : begin q_out<=8'd0;rs_out<=1'b0;en_out<=1'b0;end
			State_init      : begin q_out<=init_out_q;rs_out<=init_out_rs;en_out<=init_out_en;end
			State_wait_init : begin q_out<=init_out_q;rs_out<=init_out_rs;en_out<=init_out_en;end
			State_Wait_work : begin q_out<=8'd0;rs_out<=1'b0;en_out<=1'b0;end
			State_Work_cmd  : begin q_out<=cmd_q;rs_out<=cmd_rs;en_out<=cmd_en;end
			State_Work_data : begin q_out<=data_q;rs_out<=data_rs;en_out<=data_en;end
			default : begin q_out<=8'd0;rs_out<=1'b0;en_out<=1'b0;end
		endcase
	end
endmodule 