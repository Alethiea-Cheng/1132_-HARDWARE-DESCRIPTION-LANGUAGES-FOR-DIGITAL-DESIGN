// ! 有六個東西要加起來，選擇使用一次加6個的加法器，還是一次加2個的加法器分五次加，取決於這個步驟會不會被執行非常多次，如果是的話就一次加；如果只執行一次就分多次加，；如果總cycle數會很少(看wave時可以知道)，就分很多次加
`define ELEMENT_NUM 6
module huffman ( clk, reset, gray_valid, gray_data, CNT_valid, CNT1, CNT2, CNT3, CNT4, CNT5, CNT6,  
code_valid, HC1, HC2, HC3, HC4, HC5, HC6, M1, M2, M3, M4, M5, M6);

input clk;
input reset;
input gray_valid; // input valid
input [7:0] gray_data; // input data A1~A6
output reg CNT_valid; // A1~A6 counting done
output reg [7:0] CNT1, CNT2, CNT3, CNT4, CNT5, CNT6; // A1~A6 counting
output reg code_valid; // Huffman Code done
output reg [7:0] HC1, HC2, HC3, HC4, HC5, HC6; // Huffman code
output reg [7:0] M1, M2, M3, M4, M5, M6; // Huffman code's mask
// ===========================================================
localparam READ = 0; // 讀入100比A1~A6資料
localparam INIT = 1; // READ - COMBINE間喘息一個state用於初始化需要用到的變數
localparam SORT0 = 2; // 先把集團內計數加總
localparam SORT1 = 3; // Bubble Sort Swap
localparam COMBINE0 = 4; // Create Huffman Code (HC)
localparam COMBINE1 = 5; // Merge Group
localparam FLIP = 6; // 使HC read順序正確
localparam FINISH = 7; 

reg [2:0] cstate;
reg [2:0] nstate;

// ! 每個dimension都要寫註解不然過一陣子回來看不懂
reg [14:0] proc_buf[6:1]; //Group 1-6 (成員:index1-6)
reg [7:0] counter; // counter開大還有一個好處，如果需要兩個counter還可以切半同時使用
reg [7:0] CNT_reg[6:0]; // 0 for special use
reg [7:0] HC_reg[6:0]; // 0 for special use
reg [7:0] M_reg[6:0]; // 0 for special use

reg [2:0] pass; // bubble sort pass
reg [2:0] j; // bubble sort processing index
wire [2:0] k =  j + 1; // bubble sort processing index
reg [2:0] C; // Group merge processing index
reg [6:0] sum1, sum2; // 用於bubble sort計算group count加總，最多100
reg [2:0] flip_boarder; // FLIP state翻轉時最大有HC的index為何


integer i;

always@*begin
    CNT1 = CNT_reg[1];
    CNT2 = CNT_reg[2];
    CNT3 = CNT_reg[3];
    CNT4 = CNT_reg[4];
    CNT5 = CNT_reg[5];
    CNT6 = CNT_reg[6];
    HC1 = HC_reg[1];
    HC2 = HC_reg[2];
    HC3 = HC_reg[3];
    HC4 = HC_reg[4];
    HC5 = HC_reg[5];
    HC6 = HC_reg[6];
    M1 = M_reg[1];
    M2 = M_reg[2];
    M3 = M_reg[3];
    M4 = M_reg[4];
    M5 = M_reg[5];
    M6 = M_reg[6];
end

always@*begin
    if(M_reg[counter][4])begin
        flip_boarder = 4;
    end
    else if(M_reg[counter][3])begin
        flip_boarder = 3;
    end
    else if(M_reg[counter][2])begin
        flip_boarder = 2;
    end
    else if(M_reg[counter][1])begin
        flip_boarder = 1;
    end
    else begin
        flip_boarder = 0;
    end
end

always@(posedge clk or posedge reset)begin
    if(reset)begin
        cstate <= READ;
        counter <= 0;
        CNT_valid <= 0;
        code_valid <= 0;
        C <= 0;
        for( i = 0 ; i < 7; i = i + 1)begin
            CNT_reg[i] <= 0;
            M_reg[i] <= 0;
            HC_reg[i] <= 0;
        end
    end
    else begin
        cstate <= nstate;
        case(cstate)
            READ:begin
                if(gray_valid)begin
                    counter <= counter + 1;
                    CNT_reg[gray_data] <= CNT_reg[gray_data] + 1;
                end
            end
            INIT:begin 
                CNT_valid <= 1;
                // ! tb2因為要求index小者優先推0，又buuble sort是穩定排序，故初始化放的順序必須把小index放在高位
                proc_buf[6] <= 1; // Group 6 highest priority (root)
                proc_buf[5] <= 2;
                proc_buf[4] <= 3;
                proc_buf[3] <= 4;
                proc_buf[2] <= 5;
                proc_buf[1] <= 6;
                counter <= 0;
                pass <= 0;
                // is_change_flag <= 0;
                j <= 1;
                sum1 <= 0;
                sum2 <= 0;
            end
            // ! sort原則：確定目標，只顧頭尾，相信數學歸納法
            // ! 像這題，需要把演算法的過程具象化，trace sort的每一步，畫出tree並寫出編碼，一步一步檢查是不是如預期
            SORT0:begin
                // ! reg[index1:index0]不可以是變數，試著去想像一下長出的電路你就會知道tool沒辦法生出這種未知連續index的selecttion電路，除非窮舉
                sum1 <= /*sum1 + */CNT_reg[proc_buf[j][14:12]] + CNT_reg[proc_buf[j][11:9]] + CNT_reg[proc_buf[j][8:6]] + CNT_reg[proc_buf[j][5:3]] + CNT_reg[proc_buf[j][2:0]]; // 應大 // 把集團內所有成員計數加總
                sum2 <= /*sum2 + */CNT_reg[proc_buf[k][14:12]] + CNT_reg[proc_buf[k][11:9]] + CNT_reg[proc_buf[k][8:6]] + CNT_reg[proc_buf[k][5:3]] + CNT_reg[proc_buf[k][2:0]]; // 應小 // 把集團內所有成員計數加總
            end
            SORT1:begin
                if(sum1 > sum2)begin // bubble sort，順序反了，交換
                    // is_change_flag <= 1;
                    proc_buf[k] <= proc_buf[j];
                    proc_buf[j] <= proc_buf[k];
                end
                if( pass == `ELEMENT_NUM - 1 - 1 && j == `ELEMENT_NUM - pass - 1)begin // 全排好
                    // is_change_flag <= 0;
                    j <= 1;
                    pass <= 0;
                end
                else if( j == `ELEMENT_NUM - pass - 1)begin // 一個集團排好 // 我不要Cascade MUX // 最後的-1是為了verilog的特性
                    // is_change_flag <= 0;
                    j <= 1;
                    pass <= pass + 1;
                end
                else begin
                    j <= j + 1;
                end
                sum1 <= 0;
                sum2 <= 0;
                counter <= 0;
            end
            COMBINE0:begin // index大合併到上去
                counter <= counter + 1;
                // * 機率大者，推0進去
                // * 機率小者，推1進去

                HC_reg[proc_buf[C + 2][2:0]] <= (HC_reg[proc_buf[C + 2][2:0]] << 1);
                M_reg[proc_buf[C + 2][2:0]] <= (M_reg[proc_buf[C + 2][2:0]] << 1) | 8'b1;
                HC_reg[proc_buf[C + 1][2:0]] <= (HC_reg[proc_buf[C + 1][2:0]] << 1) | 8'b1;
                M_reg[proc_buf[C + 1][2:0]] <= (M_reg[proc_buf[C + 1][2:0]] << 1) | 8'b1;

                HC_reg[proc_buf[C + 2][5:3]] <= (HC_reg[proc_buf[C + 2][5:3]] << 1);
                M_reg[proc_buf[C + 2][5:3]] <= (M_reg[proc_buf[C + 2][5:3]] << 1) | 8'b1;
                HC_reg[proc_buf[C + 1][5:3]] <= (HC_reg[proc_buf[C + 1][5:3]] << 1) | 8'b1;
                M_reg[proc_buf[C + 1][5:3]] <= (M_reg[proc_buf[C + 1][5:3]] << 1) | 8'b1;

                HC_reg[proc_buf[C + 2][8:6]] <= (HC_reg[proc_buf[C + 2][8:6]] << 1);
                M_reg[proc_buf[C + 2][8:6]] <= (M_reg[proc_buf[C + 2][8:6]] << 1) | 8'b1;
                HC_reg[proc_buf[C + 1][8:6]] <= (HC_reg[proc_buf[C + 1][8:6]] << 1) | 8'b1;
                M_reg[proc_buf[C + 1][8:6]] <= (M_reg[proc_buf[C + 1][8:6]] << 1) | 8'b1;

                HC_reg[proc_buf[C + 2][11:9]] <= (HC_reg[proc_buf[C + 2][11:9]] << 1);
                M_reg[proc_buf[C + 2][11:9]] <= (M_reg[proc_buf[C + 2][11:9]] << 1) | 8'b1;
                HC_reg[proc_buf[C + 1][11:9]] <= (HC_reg[proc_buf[C + 1][11:9]] << 1) | 8'b1;
                M_reg[proc_buf[C + 1][11:9]] <= (M_reg[proc_buf[C + 1][11:9]] << 1) | 8'b1;

                HC_reg[proc_buf[C + 2][14:12]] <= (HC_reg[proc_buf[C + 2][14:12]] << 1);
                M_reg[proc_buf[C + 2][14:12]] <= (M_reg[proc_buf[C + 2][14:12]] << 1) | 8'b1;
                HC_reg[proc_buf[C + 1][14:12]] <= (HC_reg[proc_buf[C + 1][14:12]] << 1) | 8'b1;
                M_reg[proc_buf[C + 1][14:12]] <= (M_reg[proc_buf[C + 1][14:12]] << 1) | 8'b1;
                C <= C + 1;
            end
            COMBINE1:begin
                counter <= 1; // for FLIP state
                j <= 1; // for SORT0 SORT1 state
                // is_change_flag <= 0;
                proc_buf[C + 1] <= (proc_buf[C + 1] << 3) | proc_buf[C][2:0];
                proc_buf[C] <= proc_buf[C] >> 3; 
            end
            FLIP:begin
                counter <= counter + 1;
                for( i = 0; i <= 1 ; i = i + 1)begin // x [4] [3] [2] [1] [0] <<    ->    [0] [1] [2] [3] [4]
                    if(M_reg[counter][i])begin
                        HC_reg[counter][i] <= HC_reg[counter][flip_boarder - i];
                        HC_reg[counter][flip_boarder - i] <= HC_reg[counter][i];
                    end
                end
            end
            FINISH:begin
                code_valid <= 1;
            end
        endcase
    end
end

always@*begin
    if(reset)begin
        nstate = READ;
    end
    else begin
        nstate = 'bx;
        case(cstate)
            READ:begin
                if(counter == 100)begin
                    nstate = INIT;
                end
                else begin
                    nstate = READ;
                end
            end
            INIT:begin
                nstate = SORT0;
            end
            SORT0:begin
                nstate = SORT1;
            end
            SORT1:begin
                if(pass == `ELEMENT_NUM - 1 - 1 && j == `ELEMENT_NUM - pass - 1)begin
                    nstate = COMBINE0;
                end
                else begin
                    nstate = SORT0;
                end
            end
            COMBINE0:begin
                nstate = COMBINE1;
            end
            COMBINE1:begin
                if( C == 5 && !((proc_buf[C] >> 3)))begin // 合併結束
                    nstate = FLIP;
                end
                else if(!(proc_buf[C] >> 3))begin // 推光了。 proc_buf[C] >> 3 == 0
                    nstate = SORT0;
                end
                else begin 
                    nstate = COMBINE1;
                end
            end
            FLIP:begin
                if(counter == 6)begin
                    nstate = FINISH;
                end
                else begin
                    nstate = FLIP;
                end
            end
            FINISH:begin
                nstate = FINISH;
            end
        endcase
    end
end

endmodule

