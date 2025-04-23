// ADD、SUB: 何時Saturation? OV時
// 自己寫CLA不會比tool自動合成來的有效率
// 結合用cycle_cnt結合state machine跟pipeline

// `define MAX 16'sh7FFF  // 最大值 ≈  31.999
// `define MIN 16'sh8000  // 最小值 = -32
// // `define SAT16(val) ((val > `MAX) ? `MAX : ((val < `MIN) ? `MIN : val[15:0]))
// function [15:0] sat16;
//     input signed [16:0] val;
//     begin
//         if ($signed(val) > $signed(`MAX)) sat16 = `MAX;
//         else if (val < `MIN) sat16 = `MIN;
//         else sat16 = val[15:0];
//     end
// endfunction


module alu(
        input clk,
        input rst,
        input [2:0] operation,

        input [15:0] srcA_i,
        input [15:0] srcB_i,
        input [15:0] sortNum0_i,
        input [15:0] sortNum1_i,
        input [15:0] sortNum2_i,
        input [15:0] sortNum3_i,
        input [15:0] sortNum4_i,
        input [15:0] sortNum5_i,
        input [15:0] sortNum6_i,
        input [15:0] sortNum7_i,
        input [15:0] sortNum8_i,

        output reg [15:0] data_o,
        output reg [15:0] sortNum0_o,
        output reg [15:0] sortNum1_o,
        output reg [15:0] sortNum2_o,
        output reg [15:0] sortNum3_o,
        output reg [15:0] sortNum4_o,
        output reg [15:0] sortNum5_o,
        output reg [15:0] sortNum6_o,
        output reg [15:0] sortNum7_o,
        output reg [15:0] sortNum8_o,
        output reg           done
);


// localparam signed [15:0] MAX = 16'sh7FFF;
// localparam signed [15:0] MIN = 16'sh8000;

// Operation codes
localparam [2:0] OP_ADD  = 3'b000;
localparam [2:0] OP_SUB  = 3'b001;
localparam [2:0] OP_MUL  = 3'b010;
localparam [2:0] OP_DIV  = 3'b011;
localparam [2:0] OP_SORT = 3'b100;

localparam OP = 0;
localparam IDLE = 30;
localparam ADD_1 = 1;
localparam SUB_1 = 2;
localparam MUL_1 = 3;
localparam MUL_2 = 4;
localparam MUL_3 = 5;
localparam DIV_1 = 6;
localparam DIV_2 = 7;
localparam DIV_3 = 8;
localparam DIV_4 = 9;
localparam SORT_1 = 10;
localparam SORT_2 = 11;
localparam SORT_3 = 12;
localparam SORT_4 = 13;
localparam SORT_5 = 14;
localparam SORT_6 = 15;
localparam SORT_7 = 16;
localparam SORT_8 = 17;
localparam SORT_9 = 18;
localparam SORT_10 = 19;
localparam OUT = 31; 

reg signed [15:0] result;
reg OV, UN;

reg signed [32:0] P;
wire signed [15:0] P_result = P[26:11] + (P[10]&(^P[9:1]) | P[11]&P[10]&(~^P[9:1]));
wire round_bit = P[27:11] + (P[10]&(^P[9:1]) | P[11]&P[10]&(~^P[9:1]));
reg [3:0] cycle_cnt;
reg [15:0] srcA_i_tmp;

reg [15:0] divisor;
reg [31:0] remainder;
reg contrary_sign_flag;
reg [4:0]cycle_cnt2;
wire [15:0] srcA_i_n = ~srcA_i + 1;

reg [15:0] sortNum[0:15];

assign sortNum0_o = sortNum[0];
assign sortNum1_o = sortNum[1];
assign sortNum2_o = sortNum[2];
assign sortNum3_o = sortNum[3];
assign sortNum4_o = sortNum[4];
assign sortNum5_o = sortNum[5];
assign sortNum6_o = sortNum[6];
assign sortNum7_o = sortNum[7];
assign sortNum8_o = sortNum[8];

reg [4:0] cstate, nstate;

always@(posedge clk or posedge rst)begin
        if(rst)begin
                done <= 0;
                P <= 0;
                cycle_cnt <= 0; 
                cycle_cnt2 <= 0;
                cstate <= IDLE;
                divisor <= 0;
                remainder <= 0;
                result <= 0;
                OV <= 0; 
                UN <= 0;
        end
        else begin
                cstate <= nstate;
                case(cstate)
                        IDLE:begin
                        end
                        OP:begin
                                done <= 0;
                                case(operation)
                                        OP_ADD:begin
                                                result <= $signed(srcA_i) + $signed(srcB_i);
                                                OV <= ~srcA_i[15]&~srcB_i[15];
                                                UN <= srcA_i[15]&srcB_i[15];
                                        end
                                        OP_SUB:begin
                                                result <= $signed(srcA_i) - $signed(srcB_i);
                                                OV <= ~srcA_i[15]&srcB_i[15];
                                                UN <= srcA_i[15]&~srcB_i[15];
                                        end
                                        OP_MUL:begin
                                                P <= {16'b0, srcB_i[15:0], 1'b0};
                                                srcA_i_tmp <= srcA_i;
                                                OV <= ~srcA_i[15]&~srcB_i[15] | srcA_i[15]&srcB_i[15];
                                                UN <= srcA_i[15] ^ srcB_i[15];
                                        end
                                        OP_DIV:begin
                                                contrary_sign_flag <= srcA_i[15] ^ srcB_i[15];
                                                remainder <= srcA_i[15] ? {15'b0, srcA_i_n, 1'b0} : {15'b0, srcA_i, 1'b0};
                                                divisor <= srcB_i[15] ? ~srcB_i+1 : srcB_i;
                                        end
                                        OP_SORT:begin
                                                sortNum[0] <= sortNum0_i;
                                                sortNum[1] <= sortNum1_i;
                                                sortNum[2] <= sortNum2_i;
                                                sortNum[3] <= sortNum3_i;
                                                sortNum[4] <= sortNum4_i;
                                                sortNum[5] <= sortNum5_i;
                                                sortNum[6] <= sortNum6_i;
                                                sortNum[7] <= sortNum7_i;
                                                sortNum[8] <= sortNum8_i;
                                                sortNum[9] <= 16'hFFFF;
                                                sortNum[10] <= 16'hFFFF;
                                                sortNum[11] <= 16'hFFFF;
                                                sortNum[12] <= 16'hFFFF;
                                                sortNum[13] <= 16'hFFFF;
                                                sortNum[14] <= 16'hFFFF;
                                                sortNum[15] <= 16'hFFFF;
                                        end
                                endcase
                        end
                        ADD_1:begin
                                // data_o <= sat16(result);
                                data_o <= OV&result[15] ? 16'h7FFF : UN&(~result[15]) ? 16'h8000 : result[15:0];
                        end
                        SUB_1:begin
                                // data_o <= sat16(result);
                                data_o <= OV&result[15] ? 16'h7FFF : UN&(~result[15]) ? 16'h8000 : result[15:0];
                        end
                        MUL_1:begin
                                case(P[1:0])
                                        // 3'b000:begin
                                        // end
                                        // 3'b001:begin
                                        //         P[32:17] <= $signed(P[32:17]) + $signed(srcA_i_tmp);
                                        // end
                                        // 3'b010:begin
                                        //         P[32:17] <= $signed(P[32:17]) + $signed(srcA_i_tmp);
                                        // end
                                        // 3'b011:begin
                                        //         P[32:17] <= $signed(P[32:17]) + ($signed(srcA_i_tmp) << 1);
                                        // end
                                        // 3'b100:begin
                                        //         // ! *(-2) = 乘以二再取補
                                        //         P[32:17] <= $signed(P[32:17]) + ~($signed(srcA_i_tmp) << 1) + 1;
                                        // end
                                        // 3'b101:begin
                                        //         P[32:17] <= $signed(P[32:17]) + ~$signed(srcA_i_tmp) + 1;
                                        // end
                                        // 3'b110:begin
                                        //         P[32:17] <= $signed(P[32:17]) + ~$signed(srcA_i_tmp) + 1;
                                        // end
                                        // 3'b111:begin
                                        // end
                                        2'b00:begin
                                        end
                                        2'b01:begin
                                                P[32:17] <= $signed(P[32:17]) + $signed(srcA_i_tmp);
                                        end
                                        2'b10:begin
                                                P[32:17] <= $signed(P[32:17]) - $signed(srcA_i_tmp);
                                        end
                                        2'b11:begin
                                        end
                                endcase
                        end
                        MUL_2:begin
                                P <= P >>> 1;
                                cycle_cnt <= cycle_cnt + 1;
                        end
                        MUL_3:begin
                                data_o <= OV&P_result[15] ? 16'h7FFF : UN&(~P_result[15]) ? 16'h8000 : P_result;
                        end
                        DIV_1:begin
                                remainder[31:16] <= remainder[31:16] > divisor ? remainder[31:16] - divisor : remainder[31:16];
                        end
                        DIV_2:begin // remainder[31:16] - divisor > 0
                                remainder <= {remainder[30:0], 1'b1};
                                cycle_cnt2 <= cycle_cnt2 + 1;
                        end
                        DIV_3:begin // remainder[31:16] - divisor < 0
                                remainder <= remainder << 1;
                                cycle_cnt2 <= cycle_cnt2 + 1;
                        end
                        DIV_4:begin
                                data_o <= contrary_sign_flag ? ~remainder[15:0]+1 : remainder[15:0];
                        end
                        SORT_1:begin
                                sortNum[0] <= sortNum[0] > sortNum[1] ? sortNum[1] : sortNum[0];
                                sortNum[1] <= sortNum[0] > sortNum[1] ? sortNum[0] : sortNum[1];
                                sortNum[2] <= sortNum[2] < sortNum[3] ? sortNum[3] : sortNum[2];
                                sortNum[3] <= sortNum[2] < sortNum[3] ? sortNum[2] : sortNum[3];
                                sortNum[4] <= sortNum[4] > sortNum[5] ? sortNum[5] : sortNum[4];
                                sortNum[5] <= sortNum[4] > sortNum[5] ? sortNum[4] : sortNum[5];
                                sortNum[6] <= sortNum[6] < sortNum[7] ? sortNum[7] : sortNum[6];
                                sortNum[7] <= sortNum[6] < sortNum[7] ? sortNum[6] : sortNum[7];
                                sortNum[8] <= sortNum[8] > sortNum[9] ? sortNum[9] : sortNum[8];
                                sortNum[9] <= sortNum[8] > sortNum[9] ? sortNum[8] : sortNum[9];
                                sortNum[10] <= sortNum[10] < sortNum[11] ? sortNum[11] : sortNum[10];
                                sortNum[11] <= sortNum[10] < sortNum[11] ? sortNum[10] : sortNum[11];
                                sortNum[12] <= sortNum[12] > sortNum[13] ? sortNum[13] : sortNum[12];
                                sortNum[13] <= sortNum[12] > sortNum[13] ? sortNum[12] : sortNum[13];
                                sortNum[14] <= sortNum[14] < sortNum[15] ? sortNum[15] : sortNum[14];
                                sortNum[15] <= sortNum[14] < sortNum[15] ? sortNum[14] : sortNum[15];
                        end
                        SORT_2:begin
                                sortNum[0] <= sortNum[0] > sortNum[2] ? sortNum[2] : sortNum[0];
                                sortNum[2] <= sortNum[0] > sortNum[2] ? sortNum[0] : sortNum[2];
                                sortNum[1] <= sortNum[1] > sortNum[3] ? sortNum[3] : sortNum[1];
                                sortNum[3] <= sortNum[1] > sortNum[3] ? sortNum[1] : sortNum[3];
                                sortNum[4] <= sortNum[4] < sortNum[6] ? sortNum[6] : sortNum[4];
                                sortNum[6] <= sortNum[4] < sortNum[6] ? sortNum[4] : sortNum[6];
                                sortNum[5] <= sortNum[5] < sortNum[7] ? sortNum[7] : sortNum[5];
                                sortNum[7] <= sortNum[5] < sortNum[7] ? sortNum[5] : sortNum[7];
                                sortNum[8] <= sortNum[8] > sortNum[10] ? sortNum[10] : sortNum[8];
                                sortNum[10] <= sortNum[8] > sortNum[10] ? sortNum[8] : sortNum[10];
                                sortNum[9] <= sortNum[9] > sortNum[11] ? sortNum[11] : sortNum[9];
                                sortNum[11] <= sortNum[9] > sortNum[11] ? sortNum[9] : sortNum[11];
                                sortNum[12] <= sortNum[12] < sortNum[14] ? sortNum[14] : sortNum[12];
                                sortNum[14] <= sortNum[12] < sortNum[14] ? sortNum[12] : sortNum[14];
                                sortNum[13] <= sortNum[13] < sortNum[15] ? sortNum[15] : sortNum[13];
                                sortNum[15] <= sortNum[13] < sortNum[15] ? sortNum[13] : sortNum[15];
                        end
                        SORT_3:begin
                                //                   怎樣                     就交換
                                sortNum[0] <= sortNum[0] > sortNum[1] ? sortNum[1] : sortNum[0]; 
                                sortNum[1] <= sortNum[0] > sortNum[1] ? sortNum[0] : sortNum[1];
                                sortNum[2] <= sortNum[2] > sortNum[3] ? sortNum[3] : sortNum[2];
                                sortNum[3] <= sortNum[2] > sortNum[3] ? sortNum[2] : sortNum[3];
                                sortNum[4] <= sortNum[4] < sortNum[5] ? sortNum[5] : sortNum[4];
                                sortNum[5] <= sortNum[4] < sortNum[5] ? sortNum[4] : sortNum[5];
                                sortNum[6] <= sortNum[6] < sortNum[7] ? sortNum[7] : sortNum[6];
                                sortNum[7] <= sortNum[6] < sortNum[7] ? sortNum[6] : sortNum[7];
                                sortNum[8] <= sortNum[8] > sortNum[9] ? sortNum[9] : sortNum[8];
                                sortNum[9] <= sortNum[8] > sortNum[9] ? sortNum[8] : sortNum[9];
                                sortNum[10] <= sortNum[10] > sortNum[11] ? sortNum[11] : sortNum[10];
                                sortNum[11] <= sortNum[10] > sortNum[11] ? sortNum[10] : sortNum[11];
                                sortNum[12] <= sortNum[12] < sortNum[13] ? sortNum[13] : sortNum[12];
                                sortNum[13] <= sortNum[12] < sortNum[13] ? sortNum[12] : sortNum[13];
                                sortNum[14] <= sortNum[14] < sortNum[15] ? sortNum[15] : sortNum[14];
                                sortNum[15] <= sortNum[14] < sortNum[15] ? sortNum[14] : sortNum[15];
                        end
                        SORT_4:begin
                                sortNum[0] <= sortNum[0] > sortNum[4] ? sortNum[4] : sortNum[0]; 
                                sortNum[4] <= sortNum[0] > sortNum[4] ? sortNum[0] : sortNum[4];
                                sortNum[1] <= sortNum[1] > sortNum[5] ? sortNum[5] : sortNum[1];
                                sortNum[5] <= sortNum[1] > sortNum[5] ? sortNum[1] : sortNum[5];
                                sortNum[2] <= sortNum[2] > sortNum[6] ? sortNum[6] : sortNum[2];
                                sortNum[6] <= sortNum[2] > sortNum[6] ? sortNum[2] : sortNum[6];
                                sortNum[3] <= sortNum[3] > sortNum[7] ? sortNum[7] : sortNum[3];
                                sortNum[7] <= sortNum[3] > sortNum[7] ? sortNum[3] : sortNum[7];
                                sortNum[8] <= sortNum[8] < sortNum[12] ? sortNum[12] : sortNum[8];
                                sortNum[12] <= sortNum[8] < sortNum[12] ? sortNum[8] : sortNum[12];
                                sortNum[9] <= sortNum[9] < sortNum[13] ? sortNum[13] : sortNum[9];
                                sortNum[13] <= sortNum[9] < sortNum[13] ? sortNum[9] : sortNum[13];
                                sortNum[10] <= sortNum[10] < sortNum[14] ? sortNum[14] : sortNum[10];
                                sortNum[14] <= sortNum[10] < sortNum[14] ? sortNum[10] : sortNum[14];
                                sortNum[11] <= sortNum[11] < sortNum[15] ? sortNum[15] : sortNum[11];
                                sortNum[15] <= sortNum[11] < sortNum[15] ? sortNum[11] : sortNum[15];
                        end
                        SORT_5:begin
                                sortNum[0] <= sortNum[0] > sortNum[2] ? sortNum[2] : sortNum[0];
                                sortNum[2] <= sortNum[0] > sortNum[2] ? sortNum[0] : sortNum[2];
                                sortNum[1] <= sortNum[1] > sortNum[3] ? sortNum[3] : sortNum[1];
                                sortNum[3] <= sortNum[1] > sortNum[3] ? sortNum[1] : sortNum[3];
                                sortNum[4] <= sortNum[4] > sortNum[6] ? sortNum[6] : sortNum[4];
                                sortNum[6] <= sortNum[4] > sortNum[6] ? sortNum[4] : sortNum[6];
                                sortNum[5] <= sortNum[5] > sortNum[7] ? sortNum[7] : sortNum[5];
                                sortNum[7] <= sortNum[5] > sortNum[7] ? sortNum[5] : sortNum[7];
                                sortNum[8] <= sortNum[8] < sortNum[10] ? sortNum[10] : sortNum[8];
                                sortNum[10] <= sortNum[8] < sortNum[10] ? sortNum[8] : sortNum[10];
                                sortNum[9] <= sortNum[9] < sortNum[11] ? sortNum[11] : sortNum[9];
                                sortNum[11] <= sortNum[9] < sortNum[11] ? sortNum[9] : sortNum[11];
                                sortNum[12] <= sortNum[12] < sortNum[14] ? sortNum[14] : sortNum[12];
                                sortNum[14] <= sortNum[12] < sortNum[14] ? sortNum[12] : sortNum[14];
                                sortNum[13] <= sortNum[13] < sortNum[15] ? sortNum[15] : sortNum[13];
                                sortNum[15] <= sortNum[13] < sortNum[15] ? sortNum[13] : sortNum[15];
                        end
                        SORT_6:begin
                                sortNum[0] <= sortNum[0] > sortNum[1] ? sortNum[1] : sortNum[0]; 
                                sortNum[1] <= sortNum[0] > sortNum[1] ? sortNum[0] : sortNum[1];
                                sortNum[2] <= sortNum[2] > sortNum[3] ? sortNum[3] : sortNum[2];
                                sortNum[3] <= sortNum[2] > sortNum[3] ? sortNum[2] : sortNum[3];
                                sortNum[4] <= sortNum[4] > sortNum[5] ? sortNum[5] : sortNum[4];
                                sortNum[5] <= sortNum[4] > sortNum[5] ? sortNum[4] : sortNum[5];
                                sortNum[6] <= sortNum[6] > sortNum[7] ? sortNum[7] : sortNum[6];
                                sortNum[7] <= sortNum[6] > sortNum[7] ? sortNum[6] : sortNum[7];
                                sortNum[8] <= sortNum[8] < sortNum[9] ? sortNum[9] : sortNum[8];
                                sortNum[9] <= sortNum[8] < sortNum[9] ? sortNum[8] : sortNum[9];
                                sortNum[10] <= sortNum[10] < sortNum[11] ? sortNum[11] : sortNum[10];
                                sortNum[11] <= sortNum[10] < sortNum[11] ? sortNum[10] : sortNum[11];
                                sortNum[12] <= sortNum[12] < sortNum[13] ? sortNum[13] : sortNum[12];
                                sortNum[13] <= sortNum[12] < sortNum[13] ? sortNum[12] : sortNum[13];
                                sortNum[14] <= sortNum[14] < sortNum[15] ? sortNum[15] : sortNum[14];
                                sortNum[15] <= sortNum[14] < sortNum[15] ? sortNum[14] : sortNum[15];
                        end
                        SORT_7:begin
                                sortNum[0] <= sortNum[0] > sortNum[8] ? sortNum[8] : sortNum[0]; 
                                sortNum[8] <= sortNum[0] > sortNum[8] ? sortNum[0] : sortNum[8];
                                sortNum[1] <= sortNum[1] > sortNum[9] ? sortNum[9] : sortNum[1];
                                sortNum[9] <= sortNum[1] > sortNum[9] ? sortNum[1] : sortNum[9];
                                sortNum[2] <= sortNum[2] > sortNum[10] ? sortNum[10] : sortNum[2];
                                sortNum[10] <= sortNum[2] > sortNum[10] ? sortNum[2] : sortNum[10];
                                sortNum[3] <= sortNum[3] > sortNum[11] ? sortNum[11] : sortNum[3];
                                sortNum[11] <= sortNum[3] > sortNum[11] ? sortNum[3] : sortNum[11];
                                sortNum[4] <= sortNum[4] > sortNum[12] ? sortNum[12] : sortNum[4];
                                sortNum[12] <= sortNum[4] > sortNum[12] ? sortNum[4] : sortNum[12];
                                sortNum[5] <= sortNum[5] > sortNum[13] ? sortNum[13] : sortNum[5];
                                sortNum[13] <= sortNum[5] > sortNum[13] ? sortNum[5] : sortNum[13];
                                sortNum[6] <= sortNum[6] > sortNum[14] ? sortNum[14] : sortNum[6];
                                sortNum[14] <= sortNum[6] > sortNum[14] ? sortNum[6] : sortNum[14];
                                sortNum[7] <= sortNum[7] > sortNum[15] ? sortNum[15] : sortNum[7];
                                sortNum[15] <= sortNum[7] > sortNum[15] ? sortNum[7] : sortNum[15];
                        end
                        SORT_8:begin
                                sortNum[0] <= sortNum[0] > sortNum[4] ? sortNum[4] : sortNum[0]; 
                                sortNum[4] <= sortNum[0] > sortNum[4] ? sortNum[0] : sortNum[4];
                                sortNum[1] <= sortNum[1] > sortNum[5] ? sortNum[5] : sortNum[1];
                                sortNum[5] <= sortNum[1] > sortNum[5] ? sortNum[1] : sortNum[5];
                                sortNum[2] <= sortNum[2] > sortNum[6] ? sortNum[6] : sortNum[2];
                                sortNum[6] <= sortNum[2] > sortNum[6] ? sortNum[2] : sortNum[6];
                                sortNum[3] <= sortNum[3] > sortNum[7] ? sortNum[7] : sortNum[3];
                                sortNum[7] <= sortNum[3] > sortNum[7] ? sortNum[3] : sortNum[7];
                                sortNum[8] <= sortNum[8] > sortNum[12] ? sortNum[12] : sortNum[8];
                                sortNum[12] <= sortNum[8] > sortNum[12] ? sortNum[8] : sortNum[12];
                                sortNum[9] <= sortNum[9] > sortNum[13] ? sortNum[13] : sortNum[9];
                                sortNum[13] <= sortNum[9] > sortNum[13] ? sortNum[9] : sortNum[13];
                                sortNum[10] <= sortNum[10] > sortNum[14] ? sortNum[14] : sortNum[10];
                                sortNum[14] <= sortNum[10] > sortNum[14] ? sortNum[10] : sortNum[14];
                                sortNum[11] <= sortNum[11] > sortNum[15] ? sortNum[15] : sortNum[11];
                                sortNum[15] <= sortNum[11] > sortNum[15] ? sortNum[11] : sortNum[15];
                        end
                        SORT_9:begin
                                sortNum[0] <= sortNum[0] > sortNum[2] ? sortNum[2] : sortNum[0];
                                sortNum[2] <= sortNum[0] > sortNum[2] ? sortNum[0] : sortNum[2];
                                sortNum[1] <= sortNum[1] > sortNum[3] ? sortNum[3] : sortNum[1];
                                sortNum[3] <= sortNum[1] > sortNum[3] ? sortNum[1] : sortNum[3];
                                sortNum[4] <= sortNum[4] > sortNum[6] ? sortNum[6] : sortNum[4];
                                sortNum[6] <= sortNum[4] > sortNum[6] ? sortNum[4] : sortNum[6];
                                sortNum[5] <= sortNum[5] > sortNum[7] ? sortNum[7] : sortNum[5];
                                sortNum[7] <= sortNum[5] > sortNum[7] ? sortNum[5] : sortNum[7];
                                sortNum[8] <= sortNum[8] > sortNum[10] ? sortNum[10] : sortNum[8];
                                sortNum[10] <= sortNum[8] > sortNum[10] ? sortNum[8] : sortNum[10];
                                sortNum[9] <= sortNum[9] > sortNum[11] ? sortNum[11] : sortNum[9];
                                sortNum[11] <= sortNum[9] > sortNum[11] ? sortNum[9] : sortNum[11];
                                sortNum[12] <= sortNum[12] > sortNum[14] ? sortNum[14] : sortNum[12];
                                sortNum[14] <= sortNum[12] > sortNum[14] ? sortNum[12] : sortNum[14];
                                sortNum[13] <= sortNum[13] > sortNum[15] ? sortNum[15] : sortNum[13];
                                sortNum[15] <= sortNum[13] > sortNum[15] ? sortNum[13] : sortNum[15];
                        end
                        SORT_10:begin
                                sortNum[0] <= sortNum[0] > sortNum[1] ? sortNum[1] : sortNum[0]; 
                                sortNum[1] <= sortNum[0] > sortNum[1] ? sortNum[0] : sortNum[1];
                                sortNum[2] <= sortNum[2] > sortNum[3] ? sortNum[3] : sortNum[2];
                                sortNum[3] <= sortNum[2] > sortNum[3] ? sortNum[2] : sortNum[3];
                                sortNum[4] <= sortNum[4] > sortNum[5] ? sortNum[5] : sortNum[4];
                                sortNum[5] <= sortNum[4] > sortNum[5] ? sortNum[4] : sortNum[5];
                                sortNum[6] <= sortNum[6] > sortNum[7] ? sortNum[7] : sortNum[6];
                                sortNum[7] <= sortNum[6] > sortNum[7] ? sortNum[6] : sortNum[7];
                                sortNum[8] <= sortNum[8] > sortNum[9] ? sortNum[9] : sortNum[8];
                                sortNum[9] <= sortNum[8] > sortNum[9] ? sortNum[8] : sortNum[9];
                                sortNum[10] <= sortNum[10] > sortNum[11] ? sortNum[11] : sortNum[10];
                                sortNum[11] <= sortNum[10] > sortNum[11] ? sortNum[10] : sortNum[11];
                                sortNum[12] <= sortNum[12] > sortNum[13] ? sortNum[13] : sortNum[12];
                                sortNum[13] <= sortNum[12] > sortNum[13] ? sortNum[12] : sortNum[13];
                                sortNum[14] <= sortNum[14] > sortNum[15] ? sortNum[15] : sortNum[14];
                                sortNum[15] <= sortNum[14] > sortNum[15] ? sortNum[14] : sortNum[15];
                        end
                        OUT:begin
                                done <= 1;
                                contrary_sign_flag <= 0;
                                P <= 0;
                                remainder <= 0;
                                cycle_cnt <= 0;
                                cycle_cnt2 <= 0;
                        end
                endcase
        end
end

always@*begin
        if(rst)begin
                nstate = OP;
        end
        else begin
                nstate = 'bx;
                case(cstate)
                        IDLE:begin
                                nstate = OP;
                        end
                        OP:begin
                                case(operation)
                                        OP_ADD:begin
                                                nstate = ADD_1;
                                        end
                                        OP_SUB:begin
                                                nstate = SUB_1;
                                        end
                                        OP_MUL:begin
                                                nstate = MUL_1;
                                        end
                                        OP_DIV:begin
                                                nstate = DIV_1;
                                        end
                                        OP_SORT:begin
                                                nstate = SORT_1;
                                        end                
                                endcase
                        end
                        ADD_1:begin
                                nstate = OUT;
                        end
                        SUB_1:begin
                                nstate = OUT;
                        end
                        MUL_1:begin
                                nstate = MUL_2;
                        end
                        MUL_2:begin
                                nstate = cycle_cnt == 15 ? MUL_3 : MUL_1;
                        end
                        MUL_3:begin
                                nstate = OUT;
                        end
                        DIV_1:begin
                                nstate = remainder[31:16] > divisor ? DIV_2 : DIV_3;
                        end
                        DIV_2:begin
                                nstate = cycle_cnt2 == 25 ? DIV_4 : DIV_1;
                        end
                        DIV_3:begin
                                nstate = cycle_cnt2 == 25 ? DIV_4 : DIV_1;
                        end
                        DIV_4:begin
                                nstate = OUT;
                        end
                        SORT_1:begin
                                nstate = SORT_2;
                        end
                        SORT_2:begin
                                nstate = SORT_3;
                        end
                        SORT_3:begin
                                nstate = SORT_4;
                        end
                        SORT_4:begin
                                nstate = SORT_5;
                        end
                        SORT_5:begin
                                nstate = SORT_6;
                        end
                        SORT_6:begin
                                nstate = SORT_7;
                        end
                        SORT_7:begin
                                nstate = SORT_8;
                        end
                        SORT_8:begin
                                nstate = SORT_9;
                        end
                        SORT_9:begin
                                nstate = SORT_10;
                        end
                        SORT_10:begin
                                nstate = OUT;
                        end
                        OUT:begin
                                nstate = OP;
                        end
                endcase
        end
end


endmodule