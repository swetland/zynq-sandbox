`timescale 1ns / 1ps

module testbench(input clk);

wire [31:0]val;
wire [7:0]data;

eth_crc32 crc(
	.clk(clk),
	.en(1),
	.rst(0),
	.dat(data),
	.crc(val)
	);

reg [7:0]packet[0:15];

reg [7:0]count = 0;

assign data = packet[count[3:0]];

always_ff @(posedge clk) begin
	$display("crc %x %x",data, val);
	if (count == 16) begin
		if (val == 32'hdebb20e3)
			$display("PASS");
		else
			$display("FAIL");
		$finish();
	end
	count <= count + 1;
end

initial begin
	packet[0] = 8'h6e;
	packet[1] = 8'hb9;
	packet[2] = 8'h34;
	packet[3] = 8'h70;
	packet[4] = 8'h3b;
	packet[5] = 8'h77;
	packet[6] = 8'hc7;
	packet[7] = 8'hae;
	packet[8] = 8'h29;
	packet[9] = 8'h52;
	packet[10] = 8'h14;
	packet[11] = 8'h3e;
	packet[12] = 8'h09;
	packet[13] = 8'ha6;
	packet[14] = 8'h94;
	packet[15] = 8'h60;
end

endmodule

