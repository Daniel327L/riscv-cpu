module clk_divider #(
	parameter DIV = 26
)(
	input clk,
	output clk_dived
);

	reg [DIV-1:0] counter = 0;

	always@(posedge clk) begin
		counter <= counter +1;
	end

	assign clk_dived = counter[DIV-1];

endmodule
