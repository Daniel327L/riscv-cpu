module de10_top (
	//////////// CLOCK //////////
	input 		          		ADC_CLK_10,
	input 		          		MAX10_CLK1_50,
	input 		          		MAX10_CLK2_50,

	//////////// SDRAM //////////
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,

	//////////// SEG7 //////////
	output		     [7:0]		HEX0,
	output		     [7:0]		HEX1,
	output		     [7:0]		HEX2,
	output		     [7:0]		HEX3,
	output		     [7:0]		HEX4,
	output		     [7:0]		HEX5,

	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// VGA //////////
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		          		VGA_HS,
	output		     [3:0]		VGA_R,
	output		          		VGA_VS,

	//////////// Accelerometer //////////
	output		          		GSENSOR_CS_N,
	input 		     [2:1]		GSENSOR_INT,
	output		          		GSENSOR_SCLK,
	inout 		          		GSENSOR_SDI,
	inout 		          		GSENSOR_SDO,

	//////////// Arduino //////////
	inout 		    [15:0]		ARDUINO_IO,
	inout 		          		ARDUINO_RESET_N,

	//////////// GPIO, GPIO connect to GPIO Default //////////
	inout 		    [35:0]		GPIO
);

cpu u1(
	.clk(clk_dived),
	.reset(KEY[0]), //push buttons are active low so is the reset mechanism I designed.
	.instruction(instruction),
	.pc_out(pc_debug),
	.debug_data(reg_debug),
	.debug_addr(debug_addr)
);
	wire [3:0] debug_addr;
	assign debug_addr = SW[4:1];
	wire [31:0] pc_debug, reg_debug, instruction;
	wire [3:0] hex [5:0];
	wire [6:0] seg [5:0];
	wire [31:0] display_val = SW[0] ? reg_debug : pc_debug;
	
	wire [23:0] shown = KEY[1] ? display_val[23:0]              // released: low 24 bits , this is for showing the most significant 2 bit
										: {16'h0000, display_val[31:24]}; // pressed: top byte

	assign HEX0 = ~({1'b0, seg[0]});
	assign HEX1 = ~({1'b0, seg[1]});
	assign HEX2 = ~({1'b0, seg[2]});
	assign HEX3 = ~({1'b0, seg[3]});
	assign HEX4 = ~({1'b0, seg[4]});
	assign HEX5 = ~({1'b0, seg[5]});

	genvar i; //compile time loop counter

	generate
		for(i=0; i<6; i=i+1) begin : slice //for loop and then name block "slice"
			assign hex[i] = shown[i*4 +: 4];  //means [base +: width], alternatively, you can do shown[i*4+3 : i*4], same thing
		end
	endgenerate

hex_to_7seg_6digit u2(
	.hex0(hex[0]),
	.hex1(hex[1]),
	.hex2(hex[2]),
	.hex3(hex[3]),
	.hex4(hex[4]),
	.hex5(hex[5]),
	.seg0(seg[0]),
	.seg1(seg[1]),
	.seg2(seg[2]),
	.seg3(seg[3]),
	.seg4(seg[4]),
	.seg5(seg[5])
);

	wire clk_dived;
	
clk_divider #(.DIV(26)) u3(
	.clk(MAX10_CLK1_50),
	.clk_dived(clk_dived)
);

endmodule
