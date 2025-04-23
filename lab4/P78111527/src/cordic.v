// `define ITER 16
module cordic(
        input clk,
        input rst,
        input start,
        input [8:0] degree, //Q9.0: 0~359


        output reg [11:0] cos, //Q2.10
        output reg [11:0] sin, //Q2.10
        output reg done,

        // LUT
        output reg [5:0] addr,
        input [63:0] dout // Q9, 55
);

localparam INIT = 0;
localparam PROC = 1;
localparam D = 2;
localparam ROUND_TO_NEAREST_TIE_TO_EVEN = 3;
reg [3:0] cstate, nstate;

reg [63:0] x, y; // Q2,62
reg [63:0] z; // Q9.55
wire d = !z[63]; // 0 順 1 逆

wire [63:0] z_abs = z[63] ? ~z+1 : z; // Q9.55

always@(posedge clk or posedge rst)begin
        if(rst)begin
                cos <= 0;
                sin <= 0;
                done <= 0;
                addr <= 0;
                cstate <= INIT;

                x <= 64'h26dd3b6a00000000;//2ac06a00;
                y <= 0;
                z <= 0;


        end
        else begin
                cstate <= nstate;
                case(cstate)
                        INIT:begin
                                done <= 0;
                                if(start)begin
                                        x <= 64'h26dd3b6a00000000;//2ac06a00;
                                        y <= 0;
                                        z <= {degree,55'b0};
                                end
                        end
                        PROC:begin
                                if(d==1)begin
                                        x <= x - (y>>1);
                                        y <= y + (x>>1);
                                        z <= $signed(z) - $signed(dout[63:0]);
                                end
                                else begin
                                        x <= x + (y>>1);
                                        y <= y - (x>>1);
                                        z <= $signed(z) + $signed(dout[63:0]);
                                end
                                addr <= addr + 1;
                                // $display("z = %h", z);
                                // $display("addr = %d", addr);
                        end
                        // D:begin
                        //         d <= z[63];
                        // end
                        ROUND_TO_NEAREST_TIE_TO_EVEN:begin
                                sin <= !y[51] ? y[63:52] : |y[50:0] ? y[63:52] + 1 : y[63:52];
                                cos <= !x[51] ? x[63:52] : |x[50:0] ? x[63:52] + 1 : x[63:52];
                                done <= 1;
                                addr <= 0;
                        end
                endcase
        end
end

always@*begin
        if(rst)begin
                nstate = INIT;
        end
        else begin
                nstate = 'bx;
                case(cstate)
                        INIT:begin
                                if(start)begin
                                        nstate = PROC;
                                end
                                else begin
                                        nstate = INIT;
                                end
                        end
                        PROC:begin
                                nstate = z_abs > {31'b0, 1'b1, 32'b0} ? PROC : ROUND_TO_NEAREST_TIE_TO_EVEN;
                        end
                        // D:begin
                        //         nstate = ROUND_TO_NEAREST_TIE_TO_EVEN;
                        // end
                        ROUND_TO_NEAREST_TIE_TO_EVEN:begin
                                nstate = INIT;
                        end

                endcase
        end
end

endmodule