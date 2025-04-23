
module lut(
        input [5:0] addr,
        output reg [63:0] dout // Q9, 55
);

reg [63:0] mem [0:63]; 

initial begin
        $readmemh("../hex/my_rom_data.hex", mem);
end

always@*begin
        dout = mem[addr];
end

// tb
// integer i;

// initial begin
//     // 等待ROM讀進去 (一般模擬器會自己處理好，不過等個1個cycle比較保險)
//     #1;
    
//     // 顯示所有ROM資料
//     $display("====== LUT Contents ======");
//     for (i = 0; i < 64; i = i + 1) begin
//               $display("addr = %0d, dout = %h", i, mem[i]);
//     end
//     $display("====== End of LUT ======");

//     // 顯示完畢之後模擬停止
//     #10;
//     $finish;
// end

endmodule
