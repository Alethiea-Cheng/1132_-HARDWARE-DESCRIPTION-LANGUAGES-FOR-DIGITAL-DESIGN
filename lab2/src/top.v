`define NUM 675
module top (
                input clk,
                input rst,
                input [4:0] in_data,
                input in_valid,
                output reg[4:0] out_data,
                output reg out_valid
);
localparam RUN = 0;
localparam OUT = 1;
// localparam TERM = 2;
localparam FINISH = 3;

reg [9:0] NUM_PATTERN;
reg [1:0] round;
reg [2:0] cstate, nstate;
reg [4:0] out_data_buf [0:127];
reg [6:0] index, index_end;

integer i;

always@(posedge clk or posedge rst)begin
        if(rst)begin
                cstate <= RUN;
                out_valid <= 0;
                out_data <= 0;
                NUM_PATTERN <= 0;
                round <= 0;
                index <= 0;
                index_end <= 0;
                for( i = 0 ; i < 128; i = i + 1)begin
                        out_data_buf[i] <= 0;
                end
        end
        else begin
                cstate <= nstate;
                case(cstate)
                        RUN:begin
                                if(in_valid)begin // start
                                        NUM_PATTERN <= NUM_PATTERN + 1;
                                        if(in_data == 0 && out_data_buf[index] < 31)begin // run
                                                out_data_buf[index] <= out_data_buf[index] + 1;
                                                if(NUM_PATTERN==`NUM)begin
                                                        out_data_buf[index+1] <= 0; 
                                                        index <= 0; // prepare for OUT
                                                        index_end <= index;
                                                end
                                        end
                                        else if (in_data == 0) begin // zero_level
                                                if(round == 2)begin // term
                                                        if(NUM_PATTERN==`NUM)begin
                                                                out_data_buf[index+1] <= in_data;
                                                                out_data_buf[index+2] <= 0;
                                                                index <= 0; // prepare for OUT
                                                                index_end <= index;
                                                        end
                                                        else begin
                                                                out_data_buf[index+1] <= in_data;
                                                                out_data_buf[index+2] <= 1;
                                                                out_data_buf[index+3] <= 1; // 溢出的0
                                                                index <= index + 3;
                                                        end
                                                        round <= 0;
                                                end
                                                else begin
                                                        if(NUM_PATTERN==`NUM)begin
                                                                out_data_buf[index+1] <= in_data;
                                                                index <= 0;
                                                                index_end <= index;
                                                        end
                                                        else begin
                                                                out_data_buf[index+1] <= in_data;
                                                                out_data_buf[index+2] <= 1; // 溢出的0
                                                                index <= index + 2;
                                                                round <= round + 1;
                                                        end
                                                end
                                        end
                                        else begin // level
                                                if(round == 2)begin // term
                                                        if(NUM_PATTERN==`NUM)begin
                                                                out_data_buf[index+1] <= in_data;
                                                                out_data_buf[index+2] <= 0;
                                                                index <= 0; // prepare for OUT
                                                                index_end <= index+2;
                                                        end
                                                        else begin
                                                                out_data_buf[index+1] <= in_data;
                                                                out_data_buf[index+2] <= 1;
                                                                index <= index + 3;
                                                        end
                                                        round <= 0;
                                                end
                                                else begin
                                                        if(NUM_PATTERN==`NUM)begin
                                                                out_data_buf[index+1] <= in_data;
                                                                index <= 0; // prepare for OUT
                                                                index_end <= index+1;
                                                        end
                                                        else begin
                                                                out_data_buf[index+1] <= in_data;
                                                                index <= index + 2;
                                                                round <= round + 1;
                                                        end
                                                end
                                        end
                                end
                        end
                        OUT:begin
                                if(index == index_end+1)begin
                                        out_valid <= 0;
                                        out_data <= out_data_buf[index];
                                end
                                else if(index % 7 == 6 && out_data_buf[index] == 0)begin
                                        out_valid <= 1;
                                        out_data <= out_data_buf[index];
                                        // index <= index + 1;
                                end
                                else begin
                                        out_valid <= 1;
                                        out_data <= out_data_buf[index];
                                        index <= index + 1;
                                end
                        end
                        FINISH:begin
                                out_valid <= 0;
                                out_data <= 0;
                        end
                endcase
        end
end

always@*begin
        if(rst)begin
                nstate = RUN;
        end
        else begin
                nstate = 'bx;
                case(cstate)
                        RUN:begin
                                if(NUM_PATTERN == `NUM)begin
                                        nstate = OUT;
                                end
                                else begin
                                        nstate = RUN;
                                end
                        end
                        OUT:begin
                                if(index % 7 == 6 && out_data_buf[index] == 0)begin
                                        nstate = FINISH;                                                
                                end
                                else begin
                                        nstate = OUT;
                                end
                        end
                endcase
        end

end



endmodule