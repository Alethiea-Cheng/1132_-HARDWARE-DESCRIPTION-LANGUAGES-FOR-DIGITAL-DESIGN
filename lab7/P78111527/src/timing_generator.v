module timing_generator(
          
    input             clk,
    input             rst_n,
                    
    input  [11:0]     h_total,
    input  [11:0]     h_size,
    input  [10:0]     h_sync,
    input  [10:0]     h_start,
    input  [10:0]     v_total,
    input  [10:0]     v_size,
    input  [ 9:0]     v_sync,
    input  [ 9:0]     v_start,
    input  [22:0]     vs_reset, 

    output [26:24]    Synco
);

    reg [11:0] h_cnt;
    reg [10:0] v_cnt;

    // ===== 水平與垂直計數器 =====
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            h_cnt <= 12'd0;
            v_cnt <= 11'd0;
        end else begin
            if (h_cnt == h_total - 1) begin
                h_cnt <= 12'd0;
                if (v_cnt == v_total - 1)
                    v_cnt <= 11'd0;
                else
                    v_cnt <= v_cnt + 1;
            end else begin
                h_cnt <= h_cnt + 1;
            end
        end
    end

    // ===== 同步訊號與資料有效訊號產生 =====
    wire Vsync = (v_cnt < v_sync);
    wire Hsync = (h_cnt < h_sync);
    wire Den   = (h_cnt >= h_start && h_cnt < h_start + h_size) &&
                 (v_cnt >= v_start && v_cnt < v_start + v_size);

    // ===== 輸出組合 =====
    assign Synco = {Vsync, Hsync, Den};

endmodule
