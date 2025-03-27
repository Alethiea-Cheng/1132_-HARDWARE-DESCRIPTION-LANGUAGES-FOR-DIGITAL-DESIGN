`timescale 1ns/1ps
`include "./src/top.v"

module tb_RLC_encode;



logic  [4:0] IN_DATA;
logic  IN_VALID;
logic  [4:0] OUT_DATA;
logic  OUT_VALID, OUT_MODE;
logic CLK,RESET;
logic  [4:0] IN_NUM [0:675];
logic  [4:0] OUT_NUM[0:111];
logic [10:0] IN_DATA_NUM;
logic [10:0] OUT_COUNTER;
logic [6:0] ERROR_CNT;
logic [6:0] ANS_NUM;
logic [2:0] cnt;

string data, ans;

parameter CYCLE_TIME = 5;

top DUT(.out_data(OUT_DATA),
        .out_valid(OUT_VALID),
        .clk(CLK),.rst(RESET),
        .in_valid(IN_VALID),
        .in_data(IN_DATA));


initial begin
    `ifdef data0
        data = "./sim/data0.dat";
        ans = "./sim/ans0.dat";
        ANS_NUM = 102;
    `elsif data1
        data = "./sim/data1.dat";
        ans = "./sim/ans1.dat";
        ANS_NUM = 111;
    `elsif data2
        data = "./sim/data2.dat";
        ans = "./sim/ans2.dat";
        ANS_NUM = 94;      
    `elsif data3
        data = "./sim/data3.dat";
        ans = "./sim/ans3.dat";
        ANS_NUM = 105;
    `elsif data4
        data = "./sim/data4.dat";
        ans = "./sim/ans4.dat";
        ANS_NUM = 84;
    `endif

   `ifdef FSDB
        $fsdbDumpfile("./build/top.fsdb");
        $fsdbDumpvars;
    `elsif FSDB_ALL
        $fsdbDumpfile("./build/top.fsdb");
        $fsdbDumpvars;
        $fsdbDumpMDA;
    `endif

    $readmemh(data, IN_NUM);
    $readmemh(ans, OUT_NUM);

    #(5000)

    if(OUT_COUNTER == ANS_NUM + 1 && ERROR_CNT == 7'd0)
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
    else
    begin
        $display("\n");
        $display("        |\\/\\/\\/|     ********************************** "); 
        $display("        |      |     **                              ** "); 
        $display("        |      |     **  HELL NAH !!                 ** "); 
        $display("        | (x)(x)     **                              ** "); 
        $display("        C      _D    **  Simulation FAIL!!           ** ");
        $display("         | ,___|     **                              ** "); 
        $display("         |   /       **  Pass = %5d, Fail = %5d  ** ",ANS_NUM-ERROR_CNT,ERROR_CNT); 
        $display("        /____\\       **                              **  "); 
        $display("       /      \\      **********************************  ");
        $display("\n");
    end
        
    $finish;
end


always #(CYCLE_TIME/2) CLK=~CLK;

initial begin
    #0  RESET = 1;
        CLK   = 0;
    #10 RESET = 0;
end



///cnt
always@(posedge CLK or posedge RESET)begin
	if(RESET)cnt<=3'd0;
	else if(cnt<5)cnt<=cnt+3'd1;
	else cnt<=cnt;
end




///IN_VALID 

always@(negedge CLK or posedge RESET)begin
    if(RESET)
        IN_VALID<=0 ;
    else begin
        if((IN_DATA_NUM <10'd676) && (OUT_VALID==0) && (cnt == 3'd5))
            IN_VALID<=1;
	else
	    IN_VALID<=0;
    end
        
end



//
always@(negedge CLK or posedge RESET)begin
        if(RESET)
            IN_DATA_NUM<=10'd0;
        else begin
            if((IN_VALID==1) || (cnt == 3'd4))
                IN_DATA_NUM<=IN_DATA_NUM+10'd1;
            else
                IN_DATA_NUM<=IN_DATA_NUM;
        end
end

//IN_DATA
always@(negedge CLK or posedge RESET)begin
    if(RESET)
        IN_DATA<=5'd0;
    else begin
        if((IN_VALID) || (cnt == 3'd4) )begin
		if(IN_DATA_NUM==10'd676)
        		IN_DATA<=IN_NUM[10'd675];
		else
			IN_DATA<=IN_NUM[IN_DATA_NUM];
	end        
	else
        IN_DATA<=5'd0;
    end       
end


always_ff@(posedge CLK)
begin
    if(RESET)
    begin
        ERROR_CNT <= 7'd0;
        OUT_COUNTER<=10'd0;
    end
    else
    begin
        if(OUT_VALID && ERROR_CNT < ANS_NUM)
        begin
            OUT_COUNTER <= OUT_COUNTER + 10'd1;
            if(OUT_NUM[OUT_COUNTER] == OUT_DATA)
                ERROR_CNT <= ERROR_CNT;
            else
                ERROR_CNT <= ERROR_CNT + 1;
        end
        else if(OUT_MODE == 1'b1 && OUT_COUNTER < ANS_NUM + 1 && ERROR_CNT < ANS_NUM)
        begin
            OUT_COUNTER <= OUT_COUNTER + 10'd1;
            ERROR_CNT <= ERROR_CNT + 1;
        end
    end
end

wire [4:0] ANS = OUT_NUM[OUT_COUNTER];

always@(posedge CLK)
begin
    if(RESET)
    begin
        OUT_MODE <= 1'b0;
    end
    else
    begin
        if(OUT_VALID)
        begin
            OUT_MODE <= 1'b1;
            if(OUT_NUM[OUT_COUNTER] == OUT_DATA)
            begin
                if((OUT_COUNTER+1)%7==0)
                    $display("# %d, correct_answer: %d, out: %d, type:  term, PASS", OUT_COUNTER, OUT_NUM[OUT_COUNTER], OUT_DATA ) ;
                else if((OUT_COUNTER+1)%7==1 || (OUT_COUNTER+1)%7==3 || (OUT_COUNTER+1)%7==5)
                    $display("# %d, correct_answer: %d, out: %d, type:   run, PASS", OUT_COUNTER, OUT_NUM[OUT_COUNTER], OUT_DATA ) ;
                else
                    $display("# %d, correct_answer: %d, out: %d, type: level, PASS", OUT_COUNTER, OUT_NUM[OUT_COUNTER], OUT_DATA ) ; 
            end
            else
            begin
                if((OUT_COUNTER+1)%7==0)
                    $display("# %d, correct_answer: %d, out: %d, type:  term, ERROR", OUT_COUNTER, OUT_NUM[OUT_COUNTER], OUT_DATA ) ;
                else if((OUT_COUNTER+1)%7==1 || (OUT_COUNTER+1)%7==3 || (OUT_COUNTER+1)%7==5)
                    $display("# %d, correct_answer: %d, out: %d, type:   run, ERROR", OUT_COUNTER, OUT_NUM[OUT_COUNTER], OUT_DATA ) ;
                else
                    $display("# %d, correct_answer: %d, out: %d, type: level, ERROR", OUT_COUNTER, OUT_NUM[OUT_COUNTER], OUT_DATA ) ;
            end
        end
        else if(OUT_MODE == 1'b1 && OUT_COUNTER < ANS_NUM + 1)
        begin
            if((OUT_COUNTER+1)%7==0)
                $display("# %d, correct_answer: %d, out: %d, type:  term,INVALID ERROR", OUT_COUNTER, OUT_NUM[OUT_COUNTER], OUT_DATA ) ;
            else if((OUT_COUNTER+1)%7==1 || (OUT_COUNTER+1)%7==3 || (OUT_COUNTER+1)%7==5)
                $display("# %d, correct_answer: %d, out: %d, type:   run,INVALID ERROR", OUT_COUNTER, OUT_NUM[OUT_COUNTER], OUT_DATA ) ;
            else
                $display("# %d, correct_answer: %d, out: %d, type: level,INVALID ERROR", OUT_COUNTER, OUT_NUM[OUT_COUNTER], OUT_DATA ) ;
        end
    end
end


    
endmodule

