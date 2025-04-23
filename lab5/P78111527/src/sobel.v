module sobel(
    input clk,
    input rst,
    input [7:0] pixel_in,
    output reg busy,
    output reg valid,
    output [7:0] pixel_out
);

localparam INIT = 0;
localparam FILL = 1;
localparam PROC = 2;
localparam FINISH = 3;

reg [1:0] cstate, nstate;

reg [13:0] addr;
wire [6:0] row = addr[13:7];
wire [6:0] col = addr[6:0];
logic [7:0] pbuf[0:3][0:127];
reg [8:0] block[0:8];
// assign block[4] = pbuf[1][col];
// assign block[1] = row == 0 ? pbuf[1][col] : pbuf[0][col];
// assign block[3] = col == 0 ? pbuf[1][col] : pbuf[1][col-1];
// assign block[5] = col == 127 ? pbuf[1][col] : pbuf[1][col+1];
// assign block[7] = row == 127 ? pbuf[1][col] : pbuf[2][col];
// assign block[0] = row == 0 && col == 0 ? pbuf[1][col] : col == 0 ? pbuf[0][col] : pbuf[0][col-1];
// assign block[2] = row == 0 && col == 127 ? pbuf[1][col] : col == 127 ? pbuf[0][col] : pbuf[0][col+1];
// assign block[6] = row == 127 && col == 0 ? pbuf[1][col] : col == 0 ? pbuf[2][col] : pbuf[2][col-1];
// assign block[8] = row == 127 && col == 127 ? pbuf[1][col] : col == 127 ? pbuf[2][col] : pbuf[2][col+1];

always@*begin
        if(row == 0 && col == 0)begin
                block[0] = pbuf[1][col];//4
                block[1] = pbuf[1][col];//4
                block[2] = pbuf[1][col+1];//5
                block[3] = pbuf[1][col];//4
                block[4] = pbuf[1][col];
                block[5] = pbuf[1][col+1];
                block[6] = pbuf[2][col];//7
                block[7] = pbuf[2][col];
                block[8] = pbuf[2][col+1];
        end
        else if(row == 0 && col == 127)begin
                block[0] = pbuf[1][col-1];//3
                block[1] = pbuf[1][col];//4
                block[2] = pbuf[1][col];//4
                block[3] = pbuf[1][col-1];
                block[4] = pbuf[1][col];
                block[5] = pbuf[1][col];//4
                block[6] = pbuf[2][col-1];
                block[7] = pbuf[2][col];
                block[8] = pbuf[2][col];//7
        end
        else if(row == 127 && col == 0)begin
                block[0] = pbuf[0][col];//1
                block[1] = pbuf[0][col];
                block[2] = pbuf[0][col+1];
                block[3] = pbuf[1][col];//4
                block[4] = pbuf[1][col];
                block[5] = pbuf[1][col+1];
                block[6] = pbuf[1][col];//4
                block[7] = pbuf[1][col];//4
                block[8] = pbuf[1][col+1];//5
        end
        else if(row == 127 && col == 127)begin
                block[0] = pbuf[0][col-1];
                block[1] = pbuf[0][col];
                block[2] = pbuf[0][col];//1
                block[3] = pbuf[1][col-1];
                block[4] = pbuf[1][col];
                block[5] = pbuf[1][col];//4
                block[6] = pbuf[1][col-1];//3
                block[7] = pbuf[1][col];//4
                block[8] = pbuf[1][col];//4
        end
        else if(row == 0)begin
                block[0] = pbuf[1][col-1];//3
                block[1] = pbuf[1][col];//4
                block[2] = pbuf[1][col+1];//5
                block[3] = pbuf[1][col-1];
                block[4] = pbuf[1][col];
                block[5] = pbuf[1][col+1];
                block[6] = pbuf[2][col-1];
                block[7] = pbuf[2][col];
                block[8] = pbuf[2][col+1];
        end
        else if(row == 127)begin
                block[0] = pbuf[0][col-1];
                block[1] = pbuf[0][col];
                block[2] = pbuf[0][col+1];
                block[3] = pbuf[1][col-1];
                block[4] = pbuf[1][col];
                block[5] = pbuf[1][col+1];
                block[6] = pbuf[1][col-1];//3
                block[7] = pbuf[1][col];//4
                block[8] = pbuf[1][col+1];//5
        end
        else if(col == 0)begin
                block[0] = pbuf[0][col];//1
                block[1] = pbuf[0][col];
                block[2] = pbuf[0][col+1];
                block[3] = pbuf[1][col];//4
                block[4] = pbuf[1][col];
                block[5] = pbuf[1][col+1];
                block[6] = pbuf[2][col];//7
                block[7] = pbuf[2][col];
                block[8] = pbuf[2][col+1];
        end
        else if(col == 127)begin
                block[0] = pbuf[0][col-1];
                block[1] = pbuf[0][col];
                block[2] = pbuf[0][col];//1
                block[3] = pbuf[1][col-1];
                block[4] = pbuf[1][col];
                block[5] = pbuf[1][col];//4
                block[6] = pbuf[2][col-1];
                block[7] = pbuf[2][col];
                block[8] = pbuf[2][col];//7
        end
        else begin
                block[0] = pbuf[0][col-1];
                block[1] = pbuf[0][col];
                block[2] = pbuf[0][col+1];
                block[3] = pbuf[1][col-1];
                block[4] = pbuf[1][col];
                block[5] = pbuf[1][col+1];
                block[6] = pbuf[2][col-1];
                block[7] = pbuf[2][col];
                block[8] = pbuf[2][col+1];
        end
end

wire signed[10:0]sumx = $signed(block[0]*(-1))+$signed(block[2]*(1))+$signed(block[3]*(-2))+$signed(block[5]*(2))+$signed(block[6]*(-1))+$signed(block[8]*(1));
wire signed[10:0]sumy = $signed(block[0]*(-1))+$signed(block[1]*(-2))+$signed(block[2]*(-1))+$signed(block[6]*(1))+$signed(block[7]*(2))+$signed(block[8]*(1));
wire[23:0] mul = sumx*sumx + sumy*sumy;
wire [23:0] sqrt_result;
    // 宣告DW_sqrt
    DW_sqrt #(
        .width(24)   // 指定input/output位元數
    ) u_sqrt (
        .a(mul),
        .root(sqrt_result)
    );
assign pixel_out = sqrt_result >= 127 ? 255 : 0;

// wire [10:0]sumx_abs = sumx < 0 ? ~sumx + 1 : sumx;
// wire [10:0]sumy_abs = sumy < 0 ? ~sumy + 1 : sumy;
// reg [10:0] max, min;
// always@*begin
//         if(sumx_abs > sumy_abs)begin
//                 max = sumx_abs;
//                 min = sumy_abs;
//         end
//         else begin
//                 max = sumy_abs;
//                 min = sumx_abs;
//         end
// end
// wire [15:0] approx_sqrt = ((((max<<3)-max)>>3)) + (min>>1);
// assign pixel_out = approx_sqrt > 127 ? 255 : 0;

reg [1:0] pbuf_cnt;

integer i, j;

always@(posedge clk or posedge rst)begin
        if(rst)begin
                cstate <= INIT;
                pbuf_cnt <= 1;
                busy <= 0;
                valid <= 0;
                addr <= 0;
                // for( i = 0; i < 9; i = i + 1)begin
                //         block[i] <= 0;
                // end
                for(i = 0 ; i < 4; i = i + 1)begin
                        for(j = 0; j < 128; j = j + 1)begin
                                pbuf[i][j] <= 0;;
                        end
                end
        end
        else begin
                cstate <= nstate;
                case(cstate)
                        INIT:begin
                                busy <= 0;
                                valid <= 0;
                        end
                        FILL:begin // 1 2 
                                pbuf[pbuf_cnt][col] <= pixel_in;
                                if(col == 127)begin
                                        addr[6:0] <= 0;
                                        pbuf_cnt <= pbuf_cnt + 1;
                                end
                                else begin
                                        addr[6:0] <= addr[6:0]+1;
                                end
                                if(pbuf_cnt == 2 && col == 127)begin
                                        valid <= 1;
                                end
                        end
                        PROC:begin

                                if(addr < 16383)begin
                                        addr <= addr + 1;
                                end
                                if(col == 127)begin
                                        pbuf[0] <= pbuf[1];
                                        pbuf[1] <= pbuf[2];
                                        pbuf[2] <= pbuf[3];
                                        pbuf[2][127] <= pixel_in;
                                end
                                else begin
                                        pbuf[pbuf_cnt][col] <= pixel_in;
                                end
                                if(col == 127 && pbuf_cnt < 3)begin
                                        pbuf_cnt <= pbuf_cnt + 1;
                                end
                        end
                        FINISH:begin
                                
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
                                nstate = FILL;
                        end
                        FILL:begin
                                if(pbuf_cnt == 2 && col == 127)begin
                                        nstate = PROC;
                                end
                                else begin
                                        nstate = FILL;
                                end
                        end
                        PROC:begin
                                if(row == 127 && col == 127)begin
                                        nstate = FINISH;
                                end
                                else begin
                                        nstate = PROC;
                                end
                        end
                        FINISH:begin
                                nstate = FINISH;
                        end
                endcase
        end
end


endmodule