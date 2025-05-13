`timescale 1ns/1ps

`include "BC.v"
`include "pass_img.v"
`include "timing_generator.v"
`include "image_capture.v"
`include "image_source.v"

module DUT_tb;


reg [10:0] v_total, v_size;
reg [9:0]  v_start, v_sync;
reg [11:0] h_total, h_size;
reg [10:0] h_start, h_sync;
reg [22:0] vs_reset; 
reg rst_n,clk;

wire [26:0] synco_wire;         // output of timing_generator
wire [26:0] source_out;         // output of image_source
wire [26:0] processed_out;      // output of BC or pass_img

// wire [7:0] brightness = 8'h10;  // 可自行調整
// wire [7:0] contrast   = 8'h80;  // 128 = 100%
reg [7:0] brightness;  // 可自行調整
reg [7:0] contrast  ;  // 128 = 100%
reg       pass_flag ;  // 0: enable BC; 1: pass original



initial begin

/********** Timing parameter **********/

    #0  clk=0;
    #0  rst_n =1;

    // ======= Timing parameters: VGA 640x480@60Hz 為例 =======
    h_size  = 12'd640;
    h_total = 12'd800;
    h_sync  = 11'd96;
    h_start = 11'd144;
    v_size  = 11'd480;
    v_total = 12'd525;
    v_sync  = 10'd2;
    v_start = 10'd35;
    vs_reset = 23'h7FFFFF; // 可以先設定最大 free run

        
        // contrast   = 8'd128;  // 128 = 100%
        // brightness = 8'd0;  // 可自行調整

        // contrast   = 8'd200;  // 128 = 100%
        // brightness = 8'd200;  // 可自行調整

        // contrast   = 8'd50;  // 128 = 100%
        // brightness = 8'd50;  // 可自行調整

        // contrast   = 8'd255;  // 128 = 100%
        // brightness = 8'd10;  // 可自行調整

        contrast   = 8'd150;  // 128 = 100%
        brightness = 8'd255;  // 可自行調整

        pass_flag  = 1'b0;   // 0: enable BC; 1: pass original

	#10 rst_n =0;
	#10 rst_n =1;



#13000000
$finish;
end

always #(2.5) clk=~clk;

/********** Waveform output **********/

initial begin
                
    `ifdef FSDB
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars(0);
    `elsif FSDB_ALL
    $fsdbDumpfile("top.fsdb");
    $fsdbDumpvars(0, "+mda");
    `endif
end


 
/********** Image source **********/
image_source image_source(
   .clk(clk),
   .rst_n(rst_n),
   .Synci(synco_wire),
   .DPo(source_out));
/********** Timing generator **********/
timing_generator timing_generator(
    .Synco(synco_wire),
    .clk(clk),
    .rst_n(rst_n),
    .v_total(v_total),
    .v_sync(v_sync),
    .v_start(v_start),
    .v_size(v_size),
    .h_total(h_total),
    .h_sync(h_sync),
    .h_start(h_start),
    .h_size(h_size),
    .vs_reset(vs_reset)
);

/********** Function to be verified (DUT) **********/

`ifdef PASS_TEST
pass_img pass_img(
    .clk(clk),
    .rst_n(rst_n),
    .DPi(source_out),
    .DPo(processed_out)
);
`elsif NONE
BC bc(
    .clk(clk),
    .rst_n(rst_n),
    .DPi(source_out),
    .DPo(processed_out),
    .pass(pass_flag),
    .Brig(brightness),
    .Cont(contrast)
);
`endif

/********** Image capture (saved to BMP file) **********/

image_capture image_capture(
    .clk(clk),
    .rst_n(rst_n),
    .DPi(processed_out),
    .Hsize(h_size),
    .Vsize(v_size)
);

endmodule

