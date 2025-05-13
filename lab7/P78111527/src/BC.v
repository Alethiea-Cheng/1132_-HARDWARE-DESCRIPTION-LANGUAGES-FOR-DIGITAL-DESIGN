
module BC(
    input clk,
    input rst_n,
    input [26:0] DPi,
    input pass,
    input [7:0] Brig,
    input [7:0] Cont,

    output [26:0] DPo
);
    // ===== 將 DPi 拆成 control 與 RGB =====
    wire vsync = DPi[26];
    wire hsync = DPi[25];
    wire den   = DPi[24];
    wire [7:0] Rin = DPi[23:16];
    wire [7:0] Gin = DPi[15:8];
    wire [7:0] Bin = DPi[7:0];
// Brightness 是 sign-magnitude
wire signed [9:0] Brig_s = Brig[7] ? -{3'b0, Brig[6:0]} : {3'b0, Brig[6:0]};

// Contrast 處理（無號乘法右移）
wire [15:0] R_tmp = $unsigned(Rin) * $unsigned(Cont);
wire [15:0] G_tmp = $unsigned(Gin) * $unsigned(Cont);
wire [15:0] B_tmp = $unsigned(Bin) * $unsigned(Cont);

wire signed [10:0] R_adj = $signed({1'b0, R_tmp[15:7]}) + $signed(Brig_s);// > 255 ? 8'd255 : $signed({1'b0, R_tmp[15:7]}) + Brig_s; //< 0 ? 0 : $signed({1'b0, R_tmp[15:7]}) + Brig_s;
wire signed [10:0] G_adj = $signed({1'b0, G_tmp[15:7]}) + $signed(Brig_s);// > 255 ? 8'd255 : $signed({1'b0, G_tmp[15:7]}) + Brig_s; //< 0 ? 0 : $signed({1'b0, G_tmp[15:7]}) + Brig_s;
wire signed [10:0] B_adj = $signed({1'b0, B_tmp[15:7]}) + $signed(Brig_s);// > 255 ? 8'd255 : $signed({1'b0, B_tmp[15:7]}) + Brig_s; //< 0 ? 0 : $signed({1'b0, B_tmp[15:7]}) + Brig_s;


// OK
// 飽和判斷：以 signed 格式檢查上下界
wire [7:0] R_out = (R_adj > 255) ? 8'd255 : (R_adj < 0) ? 8'd0 : R_adj[7:0];
wire [7:0] G_out = (G_adj > 255) ? 8'd255 : (G_adj < 0) ? 8'd0 : G_adj[7:0];
wire [7:0] B_out = (B_adj > 255) ? 8'd255 : (B_adj < 0) ? 8'd0 : B_adj[7:0];

// //4出錯
// // 飽和判斷：以 signed 格式檢查上下界
// wire [7:0] R_out = (R_adj > 10'sd255) ? 8'd255 : (R_adj < 10'sd0) ? 8'd0 : R_adj[7:0];
// wire [7:0] G_out = (G_adj > 10'sd255) ? 8'd255 : (G_adj < 10'sd0) ? 8'd0 : G_adj[7:0];
// wire [7:0] B_out = (B_adj > 10'sd255) ? 8'd255 : (B_adj < 10'sd0) ? 8'd0 : B_adj[7:0];

// // 2、5出錯
// // 飽和判斷：以 signed 格式檢查上下界
// wire [7:0] R_out = (R_adj > 10'd255) ? 8'd255 : (R_adj < 10'd0) ? 8'd0 : R_adj[7:0];
// wire [7:0] G_out = (G_adj > 10'd255) ? 8'd255 : (G_adj < 10'd0) ? 8'd0 : G_adj[7:0];
// wire [7:0] B_out = (B_adj > 10'd255) ? 8'd255 : (B_adj < 10'd0) ? 8'd0 : B_adj[7:0];

// // 4
// // 飽和判斷：以 signed 格式檢查上下界
// wire [7:0] R_out = ($signed(R_adj) > $signed(10'd255)) ? 8'd255 : ($signed(R_adj) < $signed(10'd0)) ? 8'd0 : R_adj[7:0];
// wire [7:0] G_out = ($signed(G_adj) > $signed(10'd255)) ? 8'd255 : ($signed(G_adj) < $signed(10'd0)) ? 8'd0 : G_adj[7:0];
// wire [7:0] B_out = ($signed(B_adj) > $signed(10'd255)) ? 8'd255 : ($signed(B_adj) < $signed(10'd0)) ? 8'd0 : B_adj[7:0];

    // ===== 組合輸出訊號 =====
    assign DPo = pass ? DPi : {vsync, hsync, den, R_out, G_out, B_out};//{vsync, hsync, den, 8'd128, 8'd128, 8'd128};

endmodule



// )===== Brightne$signed(ss 為 )sig$signed(10'dn)-magnitude 格式 =====
// //     wire signed [7:0] Brig_s = Brig[7] ? -{1'b0, Brig[6:0]} : {1'b0, Brig[6:0]};

//     // ===== Contrast 調整後右移 7 bits =====
// //     wire [15:0] R_tmp = (Rin * Cont) >> 7;
// //     wire [15:0] G_tmp = (Gin * Cont) >> 7;
// //     wire [15:0] B_tmp = (Bin * Cont) >> 7;
//     reg [15:0] R_tmp1, G_tmp1, B_tmp1;
//     reg [7:0] R_tmp2, G_tmp2, B_tmp2;
//     reg signed [8:0] R_adj, G_adj, B_adj;
//     always@*begin
//         R_tmp1 = (Rin * Cont);
//         R_tmp2 = R_tmp1 >> 7;
//         G_tmp1 = (Gin * Cont);
//         G_tmp2 = G_tmp1 >> 7;
//         B_tmp1 = (Bin * Cont);
//         B_tmp2 = B_tmp1 >> 7;
//         R_adj = Brig[7] ? $unsigned(R_tmp2) - $unsigned(Brig[6:0]) : $unsigned(R_tmp2) + $unsigned(Brig[6:0]);
//         G_adj = Brig[7] ? $unsigned(G_tmp2) - $unsigned(Brig[6:0]) : $unsigned(G_tmp2) + $unsigned(Brig[6:0]);
//         B_adj = Brig[7] ? $unsigned(B_tmp2) - $unsigned(Brig[6:0]) : $unsigned(B_tmp2) + $unsigned(Brig[6:0]);
//     end 


//     // ===== 飽和處理，避免 overflow/underflow =====
//     wire [7:0] R_out = ($signed(R_adj) > 255) ? 8'd255 : ($signed(R_adj) < 0) ? 8'd0 : R_adj[7:0];
//     wire [7:0] G_out = ($signed(G_adj) > 255) ? 8'd255 : ($signed(G_adj) < 0) ? 8'd0 : G_adj[7:0];
//     wire [7:0] B_out = ($signed(B_adj) > 255) ? 8'd255 : ($signed(B_adj) < 0) ? 8'd0 : B_adj[7:0];