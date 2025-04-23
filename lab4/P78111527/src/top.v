`include "cordic.v"
`include "lut.v"

module top(
    input clk,
    input rst,
    input start,
    input [8:0] degree, //Q9.0: 0~359


    output [11:0] cos, //Q2.10
    output [11:0] sin, //Q2.10
    output done
);

wire [5:0] addr;
wire [63:0] dout; // Q9, 55

cordic cordic(
        .clk(clk),
        .rst(rst),
        .start(start),
        .degree(degree),

        .cos(cos),
        .sin(sin),
        .done(done),
        .addr(addr),
        .dout(dout) // Q9, 55
);

lut lut(
        .addr(addr),
        .dout(dout) // Q9, 55
);


endmodule
