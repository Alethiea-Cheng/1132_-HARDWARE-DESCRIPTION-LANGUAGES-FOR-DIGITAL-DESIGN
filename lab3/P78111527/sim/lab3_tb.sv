`timescale 1ns/1ps
`include "alu.v"

module lab3_tb;

logic done;
logic clk, rst;
logic [2:0] operation;

logic [15:0] srcA_i, srcB_i, data_o;

logic [15:0] sortNum0_i, sortNum1_i, sortNum2_i;
logic [15:0] sortNum3_i, sortNum4_i, sortNum5_i;
logic [15:0] sortNum6_i, sortNum7_i, sortNum8_i;

logic [15:0] sortNum0_o, sortNum1_o, sortNum2_o;
logic [15:0] sortNum3_o, sortNum4_o, sortNum5_o;
logic [15:0] sortNum6_o, sortNum7_o, sortNum8_o;

logic sort_flag0, sort_flag1, sort_flag2, sort_flag3;

logic [3:0] cnt;

real score, num, err;

always #5 clk = ~clk;

always @(posedge clk) begin
    if(rst) begin
        cnt <= 4'd0;
    end
    else begin
        if(done) begin
            cnt <= cnt + 4'd1;
        end
    end
end

alu alu(
    .clk(clk),
    .rst(rst),
    .operation(operation),
    .srcA_i(srcA_i),
    .srcB_i(srcB_i),
    .sortNum0_i(sortNum0_i),
    .sortNum1_i(sortNum1_i),
    .sortNum2_i(sortNum2_i),
    .sortNum3_i(sortNum3_i),
    .sortNum4_i(sortNum4_i),
    .sortNum5_i(sortNum5_i),
    .sortNum6_i(sortNum6_i),
    .sortNum7_i(sortNum7_i),
    .sortNum8_i(sortNum8_i),

    .data_o(data_o),
    .sortNum0_o(sortNum0_o),
    .sortNum1_o(sortNum1_o),
    .sortNum2_o(sortNum2_o),
    .sortNum3_o(sortNum3_o),
    .sortNum4_o(sortNum4_o),
    .sortNum5_o(sortNum5_o),
    .sortNum6_o(sortNum6_o),
    .sortNum7_o(sortNum7_o),
    .sortNum8_o(sortNum8_o),
    .done(done)
);

initial begin

    `ifdef FSDB
    $fsdbDumpfile("alu.fsdb");
    $fsdbDumpvars(0);
    `elsif FSDB_ALL
    $fsdbDumpfile("alu.fsdb");
    $fsdbDumpvars(0, "+mda");
    `endif

    clk = 1; rst=1;
    srcA_i = 16'd0;
    srcB_i = 16'd0;
    operation = 3'd0;
    sortNum0_i = 16'd0;
    sortNum1_i = 16'd0;
    sortNum2_i = 16'd0;
    sortNum3_i = 16'd0;
    sortNum4_i = 16'd0;
    sortNum5_i = 16'd0;
    sortNum6_i = 16'd0;
    sortNum7_i = 16'd0;
    sortNum8_i = 16'd0;

    #10
    rst=0;

    #10
    //addition: clamp to the maximum
    srcA_i = 16'h7fff; //31.9990234375
    srcB_i = 16'h0003; //0.0029296875
    operation = 3'b000;

    $display("\n*************************");
    $display("** Simulation Start!!! **");
    $display("*************************\n");


    #0.001
    wait(done);

    if (data_o == 16'h7fff)
        $display("Addition Scenario 0: Pass");
    else begin
        err = err + 1;
        $display("Addition Scenario 0: Fail; Your anwser is 16'h%4h, expected anwser is 16'h7fff", data_o);
    end

    #10
    //addition: clamp to the minimum
    srcA_i = 16'h8000; //-32
    srcB_i = 16'hc000; //-16
    operation = 3'b000;

    #0.001
    wait(done);
    
    if (data_o == 16'h8000)
        $display("Addition Scenario 1: Pass");
    else begin
        err = err + 1;
        $display("Addition Scenario 1: Fail; Your anwser is 16'h%4h, expected anwser is 16'h8000", data_o);
    end

    #10
    //addition: value test
    srcA_i = 16'hf234;
    srcB_i = 16'h5432;
    operation = 3'b000;

    #0.001
    wait(done);
    
    if (data_o == 16'h4666)
        $display("Addition Scenario 2: Pass");
    else begin
        err = err + 1;
        $display("Addition Scenario 2: Fail; Your anwser is 16'h%4h, expected anwser is 16'h4666", data_o);
    end

    #10
    //addition: value test
    srcA_i = 16'h1234;
    srcB_i = 16'hc789;
    operation = 3'b000;

    #0.001
    wait(done);
    
    if (data_o == 16'hd9bd)
        $display("Addition Scenario 0: Pass");
    else begin
        err = err + 1;
        $display("Addition Scenario 0: Fail; Your anwser is 16'h%4h, expected anwser is 16'hd9bd", data_o);
    end

    #10
    //subtraction: clamp to the maximum
    srcA_i = 16'h7ff0; //31.984375
    srcB_i = 16'hf600; //-2.5
    operation = 3'b001;

    #0.001
    wait(done);

    if (data_o == 16'h7fff)
        $display("\nSubtraction Scenario 0: Pass");
    else begin
        err = err + 1;
        $display("\nSubtraction Scenario 0: Fail; Your anwser is 16'h%4h, expected anwser = 16'h7fff", data_o);
    end

    #10
    //subtraction: clamp to the minimum
    srcA_i = 16'h8200; //-31.5
    srcB_i = 16'h7f00; //31.75
    operation = 3'b001;

    #0.001
    wait(done);

    if (data_o == 16'h8000)
        $display("Subtraction Scenario 1: Pass");
    else begin
        err = err + 1;
        $display("Subtraction Scenario 1: Fail; Your anwser is 16'h%4h, expected anwser = 16'h8000", data_o);
    end

    #10
    //subtraction: test value
    srcA_i = 16'hc789;
    srcB_i = 16'h1234;
    operation = 3'b001;

    #0.001
    wait(done);

    if (data_o == 16'hb555)
        $display("Subtraction Scenario 2: Pass");
    else begin
        err = err + 1;
        $display("Subtraction Scenario 2: Fail; Your anwser is 16'h%4h, expected anwser = 16'hb555", data_o);
    end

    #10
    //subtraction: test value
    srcA_i = 16'h1234;
    srcB_i = 16'hc789;
    operation = 3'b001;

    #0.001
    wait(done);

    if (data_o == 16'h4aab)
        $display("Subtraction Scenario 3: Pass");
    else begin
        err = err + 1;
        $display("Subtraction Scenario 3: Fail; Your anwser is 16'h%4h, expected anwser = 16'h4aab", data_o);
    end

    #10
    //multiplication: saturation
    srcA_i = 16'h8200; //-31.5
    srcB_i = 16'h7f00; //31.75
    operation = 3'b010;

    #0.001
    wait(done);

    if (data_o == 16'h8000)
        $display("\nMultiplication Scenario 0: Pass");
    else begin
        err = err + 1;
        $display("\nMultiplication Scenario 0: Fail; Your anwser is 16'h%4h, expected anwser = 16'h8000", data_o);
    end

    #10
    //multiplication: rouding1
    srcA_i = 16'h6152; //24.330078125
    srcB_i = 16'h0328; //0.7890625
    operation = 3'b010;

    #0.001
    wait(done);
    
    if (data_o == 16'h4ccb)
        $display("Multiplication Scenario 1: Pass");
    else begin
        err = err + 1;
        $display("Multiplication Scenario 1: Fail; Your anwser is 16'h%4h, expected anwser = 16'h4ccb", data_o);
    end

    #10
    //multiplication: rouding2
    srcA_i = 16'h3eb2;
    srcB_i = 16'h0100;
    operation = 3'b010;

    #0.001
    wait(done);

    if (data_o == 16'h0fac)
        $display("Multiplication Scenario 2: Pass");
    else begin
        err = err + 1;
        $display("Multiplication Scenario 2: Fail; Your anwser is 16'h%4h, expected anwser = 16'h0fac", data_o);
    end

    #10
    //multiplication: rouding3
    srcA_i = 16'h3eb6;
    srcB_i = 16'h0100;
    operation = 3'b010;

    #0.001
    wait(done);
    
    if (data_o == 16'h0fae)
        $display("Multiplication Scenario 3: Pass");
    else begin
        err = err + 1;
        $display("Multiplication Scenario 3: Fail; Your anwser is 16'h%4h, expected anwser = 16'h0fae", data_o);
    end

    #10
    //division
    srcA_i = 16'h0400; //1
    srcB_i = 16'h0c00; //3
    operation = 3'b011;

    #0.001
    wait(done);
    
    if (data_o == 16'h0155)
        $display("\nDivision Scenario 0: Pass");
    else begin
        err = err + 1;
        $display("\nDivision Scenario 0: Fail; Your anwser is 16'h%4h, expected anwser = 16'h0155", data_o);
    end

    #10
    //division
    srcA_i = 16'hfc00; //-1
    srcB_i = 16'h0c00; //3
    operation = 3'b011;

    #0.001
    wait(done);
    
    if (data_o == 16'hfeab)
        $display("Division Scenario 1: Pass");
    else begin
        err = err + 1;
        $display("Division Scenario 1: Fail; Your anwser is 16'h%4h, expected anwser = 16'hfeab", data_o);
    end

    #10
    //division
    srcA_i = 16'h0400; //1
    srcB_i = 16'hf400; //-3
    operation = 3'b011;

    #0.001
    wait(done);
    
    if (data_o == 16'hfeab)
        $display("Division Scenario 2: Pass");
    else begin
        err = err + 1;
        $display("Division Scenario 2: Fail; Your anwser is 16'h%4h, expected anwser = 16'hfeab", data_o);
    end

    #10
    //division
    srcA_i = 16'h3f94;
    srcB_i = 16'hf313;
    operation = 3'b011;

    #0.001
    wait(done);
    
    if (data_o == 16'hec54)
        $display("Division Scenario 3: Pass");
    else begin
        err = err + 1;
        $display("Division Scenario 3: Fail; Your anwser is 16'h%4h, expected anwser = 16'hec54", data_o);
    end

    //sorting
    

    #10
    srcA_i = 16'h0000;
    srcB_i = 16'h0000;
    operation = 3'b100;
    sortNum0_i = 16'd8;
    sortNum1_i = 16'd7;
    sortNum2_i = 16'd5;
    sortNum3_i = 16'd3;
    sortNum4_i = 16'd2;
    sortNum5_i = 16'd4;
    sortNum6_i = 16'd1;
    sortNum7_i = 16'd6;
    sortNum8_i = 16'd9;

    assign sort_flag0 = (sortNum0_o == 16'd1) &&
                        (sortNum1_o == 16'd2) &&
                        (sortNum2_o == 16'd3) &&
                        (sortNum3_o == 16'd4) &&
                        (sortNum4_o == 16'd5) &&
                        (sortNum5_o == 16'd6) &&
                        (sortNum6_o == 16'd7) &&
                        (sortNum7_o == 16'd8) &&
                        (sortNum8_o == 16'd9);

    #0.001
    wait(done);
    
    if (sort_flag0)
        $display("\nSort Scenario 0: Pass");
    else begin
        err = err + 1;
        $display("\nSort Scenario 0: Fail; expcted answer is: ");
        $display("%h, %h, %h, %h, %h, %h, %h, %h, %h", 
                16'd1, 16'd2, 16'd3, 
                16'd4, 16'd5, 16'd6, 
                16'd7, 16'd8, 16'd9);
        $display("Your answer is: ");
        $display("%h, %h, %h, %h, %h, %h, %h, %h, %h\n", 
                sortNum0_o, sortNum1_o, sortNum2_o, 
                sortNum3_o, sortNum4_o, sortNum5_o, 
                sortNum6_o, sortNum7_o, sortNum8_o);
    end

    #10
    assign sort_flag1 = (sortNum0_o == 16'd1) &&
                        (sortNum1_o == 16'd2) &&
                        (sortNum2_o == 16'd3) &&
                        (sortNum3_o == 16'd4) &&
                        (sortNum4_o == 16'd5) &&
                        (sortNum5_o == 16'd6) &&
                        (sortNum6_o == 16'd7) &&
                        (sortNum7_o == 16'd8) &&
                        (sortNum8_o == 16'd9);

    srcA_i = 16'h0000;
    srcB_i = 16'h0000;
    operation = 3'b100;
    sortNum0_i = 16'd1;
    sortNum1_i = 16'd3;
    sortNum2_i = 16'd2;
    sortNum3_i = 16'd5;
    sortNum4_i = 16'd4;
    sortNum5_i = 16'd7;
    sortNum6_i = 16'd6;
    sortNum7_i = 16'd9;
    sortNum8_i = 16'd8;
    #0.001
    wait(done);
    
    if (sort_flag1)
        $display("Sort Scenario 1: Pass");
    else begin
        err = err + 1;
        $display("Sort Scenario 1: Fail; expcted answer is: ");
        $display("%h, %h, %h, %h, %h, %h, %h, %h, %h", 
                16'd1, 16'd2, 16'd3, 
                16'd4, 16'd5, 16'd6, 
                16'd7, 16'd8, 16'd9);
        $display("Your answer is: ");
        $display("%h, %h, %h, %h, %h, %h, %h, %h, %h\n", 
                sortNum0_o, sortNum1_o, sortNum2_o, 
                sortNum3_o, sortNum4_o, sortNum5_o, 
                sortNum6_o, sortNum7_o, sortNum8_o);
    end

    #10
    srcA_i = 16'h0000;
    srcB_i = 16'h0000;
    operation = 3'b100;
    sortNum0_i = 16'd9;
    sortNum1_i = 16'd8;
    sortNum2_i = 16'd7;
    sortNum3_i = 16'd6;
    sortNum4_i = 16'd5;
    sortNum5_i = 16'd4;
    sortNum6_i = 16'd3;
    sortNum7_i = 16'd2;
    sortNum8_i = 16'd1;

    assign sort_flag2 = (sortNum0_o == 16'd1) &&
                        (sortNum1_o == 16'd2) &&
                        (sortNum2_o == 16'd3) &&
                        (sortNum3_o == 16'd4) &&
                        (sortNum4_o == 16'd5) &&
                        (sortNum5_o == 16'd6) &&
                        (sortNum6_o == 16'd7) &&
                        (sortNum7_o == 16'd8) &&
                        (sortNum8_o == 16'd9);

    #0.001
    wait(done);
    
    if (sort_flag2)
        $display("Sort Scenario 2: Pass");
    else begin
        err = err + 1;
        $display("Sort Scenario 2: Fail; expcted answer is: ");
        $display("%h, %h, %h, %h, %h, %h, %h, %h, %h", 
                16'd1, 16'd2, 16'd3, 
                16'd4, 16'd5, 16'd6, 
                16'd7, 16'd8, 16'd9);
        $display("Your answer is: ");
        $display("%h, %h, %h, %h, %h, %h, %h, %h, %h\n", 
                sortNum0_o, sortNum1_o, sortNum2_o, 
                sortNum3_o, sortNum4_o, sortNum5_o, 
                sortNum6_o, sortNum7_o, sortNum8_o);
    end

    #10
    srcA_i = 16'h0000;
    srcB_i = 16'h0000;
    operation = 3'b100;
    sortNum0_i = 16'd2;
    sortNum1_i = 16'd1;
    sortNum2_i = 16'd1;
    sortNum3_i = 16'd1;
    sortNum4_i = 16'd1;
    sortNum5_i = 16'd1;
    sortNum6_i = 16'd1;
    sortNum7_i = 16'd1;
    sortNum8_i = 16'd1;

    assign sort_flag3 = (sortNum0_o == 16'd1) &&
                        (sortNum1_o == 16'd1) &&
                        (sortNum2_o == 16'd1) &&
                        (sortNum3_o == 16'd1) &&
                        (sortNum4_o == 16'd1) &&
                        (sortNum5_o == 16'd1) &&
                        (sortNum6_o == 16'd1) &&
                        (sortNum7_o == 16'd1) &&
                        (sortNum8_o == 16'd2);


    #0.001
    wait(done);
    
    if (sort_flag3)
        $display("Sort Scenario 3: Pass");
    else begin
        err = err + 1;
        $display("Sort Scenario 3: Fail; expcted answer is: ");
        $display("%h, %h, %h, %h, %h, %h, %h, %h, %h", 
                16'd1, 16'd1, 16'd1, 
                16'd1, 16'd1, 16'd1, 
                16'd1, 16'd1, 16'd2);
        $display("Your answer is: ");
        $display("%h, %h, %h, %h, %h, %h, %h, %h, %h\n", 
                sortNum0_o, sortNum1_o, sortNum2_o, 
                sortNum3_o, sortNum4_o, sortNum5_o, 
                sortNum6_o, sortNum7_o, sortNum8_o);
    end

    if(err) begin
        $display("\n⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⣿⣟⣿⣟⡿⠏⠛⠛⠛⠛⢛⣛⣛⡛⡙⠛⠻⠯⠿⠟⢯⣿⣿⣯⣿⣿⣻⣿⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⣯⣿⡿⢉⣴⣿⢟⡾⢛⡿⠿⢶⢶⣾⣿⣿⣿⣿⣭⣭⣲⢶⣶⢭⣙⠻⣿⣟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⣻⡽⣀⡫⣽⣿⣿⣻⠟⠀⠀⠀⠑⢽⢿⢟⢿⣿⠏⠁⠀⠙⠿⣷⣝⢷⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⠋⣰⢟⠛⢝⣺⡭⣃⡀👁⠀⠀⣨⣗⣾⣷⢘⣄👁 ⣀⣔⢺⣟⢿⣥⠛⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿");
        $display("⡏⣵⡎⣵⣱⣶⡀⠈⠙⢯⣳⣶⣶⢂⣼⠹⠿⠛⣿⣦⢳⣄⣶⡺⠝⠈⠁⢰⠏⣷⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⡀⢿⣿⣄⣿⢿⣧⡀⠀⠀⠀⠀⠙⠛⣛⡗⣞⣉⡉⢉⣈⢭⡄⠀⠀⠀⠀⢨⣾⡹⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣷⣌⠿⣼⣜⣿⣿⡽⣦⠀⠀⠀⣼⣷⡸⣰⡎⢋⣾⣷⢣⣿⣇⠀⠀⠀⠀⣸⡏⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿            Simulation Fail !!!     ⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⣦⠙⣿⡿⣿⣿⣟⣷⣄⠀⠈⠉⠁⠛⠃⠘⠿⠿⠈⠛⠉⠀⠀⠀⠀⢿⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⣿⣧⣘⠿⡽⣿⣿⣮⣳⣱⢄⡀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠉⣷⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⢿⣽⣿⣷⣌⠙⢿⣿⣿⣿⣷⣝⢦⡀⠀⠐⣆⢷⣿⡎⣷⠀⠀⠀⠀⢠⡟⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⣿⣿⡿⣿⣻⣿⣶⣮⣭⡘⠻⢿⣷⡺⣴⣦⣥⣍⣈⣁⣀⠈⠤⣖⣶⣾⣵⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⣷⣿⣿⣿⣿⡿⣿⣻⣿⣿⣷⣦⣌⣙⣒⡶⠾⠿⣿⣿⠿⠿⠿⣻⡽⠛⢟⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⣯⣿⣷⣿⣟⣿⣿⣿⣿⣻⣿⣻⣿⣿⣿⣿⣿⣷⣶⣤⣤⣭⣥⣤⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⣟⣿⣯⣿⣿⣿⢿⣽⣾⣿⣿⢿⣿⣻⣽⣿⡿⣟⣿⣿⣿⡿⣿⣿⣿⣿⢿⣿⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\n");
    end
    else begin
        $display("\n⣿⣿⣿⣿⣿⣿⠿⢋⣥⣴⣶⣶⣶⣬⣙⠻⠟⣋⣭⣭⣭⣭⡙⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⣿⣿⡿⢋⣴⣿⣿⠿⢟⣛⣛⣛⠿⢷⡹⣿⣿⣿⣿⣿⣿⣆⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⣿⡿⢁⣾⣿⣿⣴⣿⣿⣿⣿⠿⠿⠷⠥⠱⣶⣶⣶⣶⡶⠮⠤⣌⡙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⡿⢛⡁⣾⣿⣿⣿⡿⢟⡫⢕⣪⡭⠥⢭⣭⣉⡂⣉⡒⣤⡭⡉⠩⣥⣰⠂⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⡟⢠⣿⣱⣿⣿⣿⣏⣛⢲⣾⣿⠃⠄⠐⠈⣿⣿⣿⣿⣿⣿⠄⠁⠃⢸⣿⣿⡧⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⢠⣿⣿⣿⣿⣿⣿⣿⣿⣇⣊⠙⠳⠤⠤⠾⣟⠛⠍⣹⣛⣛⣢⣀⣠⣛⡯⢉⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡶⠶⢒⣠⣼⣿⣿⣛⠻⠛⢛⣛⠉⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⣿⣿⣿⣿⣿⡿⢛⡛⢿⣿⣿⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿         Simulation Pass !!!     ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⣿⣿⣿⣿⣿⠸⣿⡻⢷⣍⣛⠻⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⢇⡘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⣿⣿⣿⣿⣿⣷⣝⠻⠶⣬⣍⣛⣛⠓⠶⠶⠶⠤⠬⠭⠤⠶⠶⠞⠛⣡⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣬⣭⣍⣙⣛⣛⣛⠛⠛⠛⠿⠿⠿⠛⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣦⣈⠉⢛⠻⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠛⣁⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⣿⣶⣮⣭⣁⣒⣒⣒⠂⠠⠬⠭⠭⠭⢀⣀⣠⣄⡘⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿");
        $display("⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\n");
    end
    num = 20;
    score = (num-err)*4.5;
    $display("=========================== Your Score is %.2f/90.00 ===========================\n", score);
    $finish;

end

endmodule