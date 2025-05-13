
module pass_img(
    input clk,
    input rst_n,
    input [26:0] DPi,
  
    output reg [26:0] DPo
);

wire [26:0] RED = {DPi[26:24], DPi[23:16], 8'b0, 8'b0};
wire [26:0] GREEN = {DPi[26:24], 8'b0, DPi[15:8], 8'b0};
wire [26:0] BLUE = {DPi[26:24], 8'b0, 8'b0, DPi[7:0]};

initial begin
        $display("**********Pass Image Test**********");
end

always @(posedge clk) begin

    if(!rst_n)begin
        DPo <= 27'd0;
    end
    else begin
        DPo <= BLUE; // modify here 1.DPi 2.RED 3.GREEN 4.BLUE
    end
        

end

endmodule
