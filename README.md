# FPGA-LCD1602-Drive
这是一个使用Verilog语言针对LCD1602屏幕开发的驱动，可以在任意FPGA上使用。
## LCD1602介绍
LCD1602（Liquid Crystal Display）液晶显示屏是一种字符型液晶显示模块，可以显示ASCII码的标准字符和其它的一些内置特殊字符，还可以有8个自定义字符。显示容量为16×2个字符，每个字符为5*7点阵。
![image](https://github.com/ascend221b/FPGA-LCD1602-Drive/assets/92852338/96781523-d500-4675-a2bd-13944ca732ea)
## 引脚及应用电路
引脚  | 功能
----- | -----
VSS  | 电源地
VDD  | 电源正极(4.5~5.5V)
VO   | 调整对比度
RS   | 数据/指令选择，1为数据，0为指令
RW   | 读/写选择，1为读，0为写
E    | 使能
D0~D7| 数据
A    | 背光灯电源正极
K    | 背光灯电源负极

![image](https://github.com/ascend221b/FPGA-LCD1602-Drive/assets/92852338/48ad9ae0-46b3-46a0-82f0-fd86018f6b3f)
## 时序
![image](https://github.com/ascend221b/FPGA-LCD1602-Drive/assets/92852338/21aeaabb-73c7-4419-ab85-ff1e818c963f)
![image](https://github.com/ascend221b/FPGA-LCD1602-Drive/assets/92852338/1a1fc90d-6f29-4f99-abed-5948116650ce)
注意：时序很简单，但这个地方有个问题，我在实际执行过程中，E信号脉冲宽度设置150ns无法顺利实现，就是在个地方我花了很长时间，最后参考单片机中的教程，整个周期给了2ms，E信号脉冲宽度设置1ms，最终实现了。
## 使用方法
```
module lcd1602_drive(
	input    wire     		   clk, //50MHz
	input    wire     	     rst_n,
													  
	input    wire     	     user_show_flag,  //显示命令，一个时钟周期
	input    wire     [15:0] user_addr_data,  // 8cmd + 8data
	output   reg             user_ready,      //lcd1602初始化结束后置1
	output   reg             show_done,       //显示完成
	
	output   reg      [7:0]  q_out,
	output   reg             rs_out,
	output   reg             en_out,
	output   wire            rw_out
);
```
当LCD1602初始化完成后，lcd1602初始化结束会置1，此时发送user_show_flag信号，并同时发送user_addr_data。user_addr_data数据的高8位是在屏幕哪个位置显示，低8位是需要显示的数据。
例如user_addr_data = 16'h8042; 表示在第1个位置显示字符A。
![image](https://github.com/ascend221b/FPGA-LCD1602-Drive/assets/92852338/168384ff-0e3b-480e-86ff-3ae604463183)
