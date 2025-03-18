`timescale 1ns/1ps
`include "./src/top.v"

module top_tb;

logic CLK, RESET;
logic [3:0] A, B;
logic Cin;
logic Cout;
logic [3:0] S;
logic [4:0] RESULT;
logic [4:0] ANSWER;
logic [4:0] ERROR_CNT, CNT;

string data, ans;

integer data_status, ans_status, file_data, file_answer, a, b, c, answer;

parameter CYCLE_TIME = 10;

top DUT(.A(A), .B(B), .Cin(Cin), .S(S), .Cout(Cout));

assign RESULT = {Cout, S};

/////////////////////FUNDAMENTAL SETUP/////////////////////

initial
begin
    `ifdef data0
        data = "./sim/data0.dat";
        ans = "./sim/ans0.dat";
    `elsif data1
        data = "./sim/data1.dat";
        ans = "./sim/ans1.dat";
    `elsif data2
        data = "./sim/data2.dat";
        ans = "./sim/ans2.dat";
    `elsif data3
        data = "./sim/data3.dat";
        ans = "./sim/ans3.dat";
    `elsif data4
        data = "./sim/data4.dat";
        ans = "./sim/ans4.dat";
    `endif

    `ifdef FSDB
        $fsdbDumpfile("./build/top.fsdb");
        $fsdbDumpvars;
    `elsif FSDB_ALL
        $fsdbDumpfile("./build/top.fsdb");
        $fsdbDumpMDA;
    `endif

    file_data = $fopen(data, "r");
    file_answer = $fopen(ans, "r");
    if(file_data==0 || file_answer==0)
    begin
        $display("Can't access file");
        $finish;
    end

    while(!$feof(file_data))
    begin
        data_status = $fscanf(file_data, "%d %d %d", a, b, c);
        ans_status = $fscanf(file_answer, "%d", answer);
        if(data_status == 3)
        begin
            @(posedge CLK);
            A <= a;
            B <= b;
            Cin <= c;
            ANSWER <= answer;
        end
    end

    if(ERROR_CNT != 0)
    begin
        $display("\n");
        $display("        |\\/\\/\\/|     ********************************** "); 
        $display("        |      |     **                              ** "); 
        $display("        |      |     **  HELL NAH !!                 ** "); 
        $display("        | (x)(x)     **                              ** "); 
        $display("        C      _D    **  Simulation FAIL!!           ** ");
        $display("         | ,___|     **                              ** "); 
        $display("         |   /       **  Pass = %5d, Fail = %5d  ** ",30-ERROR_CNT,ERROR_CNT); 
        $display("        /____\\       **                              **  "); 
        $display("       /      \\      **********************************  ");   
        $display("\n");
    end
    else
    begin
        $display("\n");
        $display("        |\\/\\/\\/|     ********************************** "); 
        $display("        |      |     **                              ** "); 
        $display("        |      |     **                              ** "); 
        $display("        | (O)(O)     **      Congratulations !!      ** "); 
        $display("        C      _D    **                              ** ");
        $display("         | ,___|     **      Simulation PASS!!!      ** "); 
        $display("         |   /       **                              ** "); 
        $display("        /____\\       **                              **  "); 
        $display("       /      \\      **********************************  ");   
        $display("\n");
    end
    $finish;
end

always #(CYCLE_TIME/2) CLK = ~CLK;

initial
begin
    #0  RESET = 1;
        CLK = 0;
    #10 RESET = 0;
end

/////////////////////FUNDAMENTAL SETUP/////////////////////


/////////////////////////COMPARISON////////////////////////

always_ff@(posedge CLK)
begin
    if(RESET)
    begin
        ERROR_CNT <= 5'd0;
        CNT <= 5'd0;
    end
    else
    begin
        if(RESULT == ANSWER)
            ERROR_CNT <= ERROR_CNT;
        else
            ERROR_CNT <= ERROR_CNT + 1;
        CNT <= CNT + 1;
        if(RESULT == ANSWER)
            $display("# %d, A=%d, B=%d, Carry_in=%d, correct_answer:%d, your_answer:%d, PASS", CNT, A, B, Cin, ANSWER, RESULT);
        else
            $display("# %d, A=%d, B=%d, Carry_in=%d, correct_answer:%d, your_answer:%d, ERROR", CNT, A, B, Cin, ANSWER, RESULT);
    end
end


/////////////////////////COMPARISON////////////////////////

endmodule