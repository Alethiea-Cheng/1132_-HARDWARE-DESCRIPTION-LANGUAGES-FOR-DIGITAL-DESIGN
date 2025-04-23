`timescale 1ns/1ps

module tb_top;

reg clk;
reg rst;
reg start;
reg [8:0] degree;

wire [11:0] cos;
wire [11:0] sin;
wire done;

// Instantiate DUT
top dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .degree(degree),
    .cos(cos),
    .sin(sin),
    .done(done)
);

// Clock generation
initial clk = 0;
always #5 clk = ~clk;

// Memory to store golden values
reg [11:0] sin_golden [0:359];
reg [11:0] cos_golden [0:359];

// Read golden files
initial begin
    $readmemh("../hex/sin_golden.hex", sin_golden);
    $readmemh("../hex/cos_golden.hex", cos_golden);
end

integer i;
integer error_count;

initial begin
    rst = 1;
    start = 0;
    degree = 0;
    error_count = 0;

    #20;
    rst = 0;

    for (i = 0; i <= 359; i = i + 1) begin
        @(posedge clk);
        degree <= i;
        start <= 1;
        @(posedge clk);
        start <= 0;

        // Wait for done signal
        wait (done == 1);

        // Compare sin and cos with golden
        if (sin !== sin_golden[i]) begin
            $display("[SIN] Mismatch at degree %0d: DUT=%03h, GOLDEN=%03h", i, sin, sin_golden[i]);
            error_count = error_count + 1;
        end else begin
            $display("[SIN] Match at degree %0d: %03h", i, sin);
        end

        if (cos !== cos_golden[i]) begin
            $display("[COS] Mismatch at degree %0d: DUT=%03h, GOLDEN=%03h", i, cos, cos_golden[i]);
            error_count = error_count + 1;
        end else begin
            $display("[COS] Match at degree %0d: %03h", i, cos);
        end

        @(posedge clk);
    end

    if (error_count == 0) begin
        $display("\nAll tests passed!\n");
    end else begin
        $display("\nTotal errors: %0d\n", error_count);
    end

    $finish;
end

endmodule